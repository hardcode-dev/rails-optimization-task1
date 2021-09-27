# Deoptimized version of homework task

require 'json'
require 'pry'
require 'csv'
require 'date'
require 'minitest/benchmark'
require 'minitest/autorun'
require 'benchmark'
require 'ruby-prof'
require 'ruby-progressbar'
require 'stackprof'
require 'set'

DATE_FORMAT = '%Y-%m-%d'

class User
  attr_reader :attributes, :sessions

  def initialize(attributes:)
    @attributes = attributes
    @sessions = []
  end

  def append_session(session)
    @sessions << session
  end

  def report_key
    @user_key ||= "#{attributes[:first_name]}" + ' ' + "#{attributes[:last_name]}"
  end
end

def parse_user(user)
  fields = user.split(',')

  {
    id: fields[1],
    first_name: fields[2],
    last_name: fields[3],
    age: fields[4]
  }
end

def parse_session(session)
  fields = session.split(',')

  {
    user_id: fields[1],
    session_id: fields[2],
    browser: fields[3],
    time: fields[4],
    date: fields[5]
  }
end

def collect_stats_from_user(report, user)
  report[:usersStats][user.report_key] ||= {}
  report[:usersStats][user.report_key].merge!(
    sessionsCount: user.sessions.count,
    totalTime: user.sessions.sum { |s| s[:time].to_i }.to_s + ' min.',
    longestSession: (user.sessions.max_by { |s| s[:time].to_i })[:time].to_s + ' min.',
    browsers: (browsers_str = user.sessions.map { |s| s[:browser].upcase }.sort.join(', ')),
    usedIE: browsers_str.match?(/INTERNET EXPLORER/),
    alwaysUsedChrome: user.sessions.none? { |s| !s[:browser].match?(/CHROME/) },
    dates: user.sessions.map { |s| s[:date].rstrip }.sort.reverse
  )

  report[:totalUsers] += 1
  report[:totalSessions] += report[:usersStats][user.report_key][:sessionsCount]
  user.sessions.each { |s| report[:allBrowsers] << s[:browser].upcase }
end

def work(filename)
  # Отчёт в json
  #   - Сколько всего юзеров
  #   - Сколько всего уникальных браузеров
  #   - Сколько всего сессий
  #   - Перечислить уникальные браузеры в алфавитном порядке через запятую и капсом
  #
  #   - По каждому пользователю
  #     - сколько всего сессий
  #     - сколько всего времени
  #     - самая длинная сессия
  #     - браузеры через запятую
  #     - Хоть раз использовал IE?
  #     - Всегда использовал только Хром?
  #     - даты сессий в порядке убывания через запятую

  users = []
  sessions = []
  report = {
    totalUsers: 0,
    totalSessions: 0,
    allBrowsers: SortedSet.new,
    uniqueBrowsersCount: 0,
    usersStats: {}
  }

  current_user = nil

  File.readlines(filename).each do |line|
    cols = line.split(',')

    if cols[0] == 'user'
      collect_stats_from_user(report, current_user) if current_user
      current_user = User.new(attributes: parse_user(line))
    elsif cols[0] == 'session' && current_user
      current_user.append_session parse_session(line)
    end
  end
  # Process last user.
  collect_stats_from_user(report, current_user)

  report[:uniqueBrowsersCount] = report[:allBrowsers].count
  report[:allBrowsers] = report[:allBrowsers].to_a.join(',')

  File.write('result.json', "#{report.to_json}\n")
end

class TestMe < Minitest::Test
  def setup
    File.write('result.json', '')
    File.write('data.txt',
      'user,0,Leida,Cira,0
session,0,0,Safari 29,87,2016-10-23
session,0,1,Firefox 12,118,2017-02-27
session,0,2,Internet Explorer 28,31,2017-03-28
session,0,3,Internet Explorer 28,109,2016-09-15
session,0,4,Safari 39,104,2017-09-27
session,0,5,Internet Explorer 35,6,2016-09-01
user,1,Palmer,Katrina,65
session,1,0,Safari 17,12,2016-10-21
session,1,1,Firefox 32,3,2016-12-20
session,1,2,Chrome 6,59,2016-11-11
session,1,3,Internet Explorer 10,28,2017-04-29
session,1,4,Chrome 13,116,2016-12-28
user,2,Gregory,Santos,86
session,2,0,Chrome 35,6,2018-09-21
session,2,1,Safari 49,85,2017-05-22
session,2,2,Firefox 47,17,2018-02-02
session,2,3,Chrome 20,84,2016-11-25
')
  end

  def test_result
    work('data.txt')
    expected_result = '{"totalUsers":3,"totalSessions":15,"allBrowsers":"CHROME 13,CHROME 20,CHROME 35,CHROME 6,FIREFOX 12,FIREFOX 32,FIREFOX 47,INTERNET EXPLORER 10,INTERNET EXPLORER 28,INTERNET EXPLORER 35,SAFARI 17,SAFARI 29,SAFARI 39,SAFARI 49","uniqueBrowsersCount":14,"usersStats":{"Leida Cira":{"sessionsCount":6,"totalTime":"455 min.","longestSession":"118 min.","browsers":"FIREFOX 12, INTERNET EXPLORER 28, INTERNET EXPLORER 28, INTERNET EXPLORER 35, SAFARI 29, SAFARI 39","usedIE":true,"alwaysUsedChrome":false,"dates":["2017-09-27","2017-03-28","2017-02-27","2016-10-23","2016-09-15","2016-09-01"]},"Palmer Katrina":{"sessionsCount":5,"totalTime":"218 min.","longestSession":"116 min.","browsers":"CHROME 13, CHROME 6, FIREFOX 32, INTERNET EXPLORER 10, SAFARI 17","usedIE":true,"alwaysUsedChrome":false,"dates":["2017-04-29","2016-12-28","2016-12-20","2016-11-11","2016-10-21"]},"Gregory Santos":{"sessionsCount":4,"totalTime":"192 min.","longestSession":"85 min.","browsers":"CHROME 20, CHROME 35, FIREFOX 47, SAFARI 49","usedIE":false,"alwaysUsedChrome":false,"dates":["2018-09-21","2018-02-02","2017-05-22","2016-11-25"]}}}' + "\n"
    assert_equal expected_result, File.read('result.json')
  end

  def test_time
    time = Benchmark.realtime { work('data.txt') }
    assert_operator time, :<, 0.1
  end
end

class TestBenchmark < Minitest::Benchmark
  def setup
    File.write('result.json', '')
    File.write('data.txt',
      'user,0,Leida,Cira,0
session,0,0,Safari 29,87,2016-10-23
session,0,1,Firefox 12,118,2017-02-27
session,0,2,Internet Explorer 28,31,2017-03-28
session,0,3,Internet Explorer 28,109,2016-09-15
session,0,4,Safari 39,104,2017-09-27
session,0,5,Internet Explorer 35,6,2016-09-01
user,1,Palmer,Katrina,65
session,1,0,Safari 17,12,2016-10-21
session,1,1,Firefox 32,3,2016-12-20
session,1,2,Chrome 6,59,2016-11-11
session,1,3,Internet Explorer 10,28,2017-04-29
session,1,4,Chrome 13,116,2016-12-28
user,2,Gregory,Santos,86
session,2,0,Chrome 35,6,2018-09-21
session,2,1,Safari 49,85,2017-05-22
session,2,2,Firefox 47,17,2018-02-02
session,2,3,Chrome 20,84,2016-11-25
')
  end

  def bench_is_linear
    assert_performance_linear 0.99 do |n|
      # n is a range value
      File.write('result.json', '')
      File.write('data.txt', '')
      n.times do
        File.write('data.txt',
          'user,0,Leida,Cira,0
session,0,0,Safari 29,87,2016-10-23
session,0,1,Firefox 12,118,2017-02-27
session,0,2,Internet Explorer 28,31,2017-03-28
session,0,3,Internet Explorer 28,109,2016-09-15
session,0,4,Safari 39,104,2017-09-27
session,0,5,Internet Explorer 35,6,2016-09-01
user,1,Palmer,Katrina,65
session,1,0,Safari 17,12,2016-10-21
session,1,1,Firefox 32,3,2016-12-20
session,1,2,Chrome 6,59,2016-11-11
session,1,3,Internet Explorer 10,28,2017-04-29
session,1,4,Chrome 13,116,2016-12-28
user,2,Gregory,Santos,86
session,2,0,Chrome 35,6,2018-09-21
session,2,1,Safari 49,85,2017-05-22
session,2,2,Firefox 47,17,2018-02-02
session,2,3,Chrome 20,84,2016-11-25
', mode: 'a')
      end
      work('data.txt')
    end
  end
end

puts Benchmark.realtime { work('data_large.txt') }

# profile = StackProf.run(mode: :wall, raw: true) do
#   work('data_large.txt')
# end
#
# File.write('reports/stackprof.json', JSON.generate(profile))

# result = RubyProf.profile do
#   work('data_large.txt')
# end
#
# printer = RubyProf::CallTreePrinter.new(result)
# printer.print(path: 'reports', profile: 'callgrind')
