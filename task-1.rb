# Deoptimized version of homework task

require 'oj'
require 'pry'
require 'date'
require 'minitest/autorun'
require 'ruby-prof'
require 'benchmark'

class User
  attr_reader :attributes, :sessions

  def initialize(attributes:, sessions:)
    @attributes = attributes
    @sessions = sessions
  end
end

def work(data_path = 'data.txt')
  file_lines = get_file_lines(data_path)

  users, sessions = parse_file_lines(file_lines)
   

  # Отчёт в json
  #   - Сколько всего юзеров +
  #   - Сколько всего уникальных браузеров +
  #   - Сколько всего сессий +
  #   - Перечислить уникальные браузеры в алфавитном порядке через запятую и капсом +
  #
  #   - По каждому пользователю
  #     - сколько всего сессий +
  #     - сколько всего времени +
  #     - самая длинная сессия +
  #     - браузеры через запятую +
  #     - Хоть раз использовал IE? +
  #     - Всегда использовал только Хром? +
  #     - даты сессий в порядке убывания через запятую +
  report = generate_report(users, sessions)

  File.write('result.json', "#{Oj.dump(report)}\n")
end

def parse_file_lines(file_lines)
  users = []
  sessions = Hash.new { |h, k| h[k] = [] }

  file_lines.each do |line|
    cols = line.chomp.split(',')

    users = users + [parse_user(cols)] if cols[0] == 'user'

    if cols[0] == 'session'
      session = parse_session(cols)
      sessions[session['user_id']] << session
    end
  end

  return [users, sessions]
end

def parse_user(fields)
  {
    'id' => fields[1],
    'first_name' => fields[2],
    'last_name' => fields[3],
    'age' => fields[4],
  }
end

def parse_session(fields)
  {
    'user_id' => fields[1],
    'session_id' => fields[2],
    'browser' => fields[3],
    'time' => fields[4],
    'date' => fields[5],
  }
end

def generate_report(users, sessions)
  report = {}

  report['totalUsers'] = users.count

  session_values = sessions.values.flatten

  # Подсчёт количества уникальных браузеров
  uniqueBrowsers = Set.new
  session_values.each do |session|
    uniqueBrowsers.add session['browser']
  end

  report['uniqueBrowsersCount'] = uniqueBrowsers.count
  report['totalSessions'] = session_values.count

  report['allBrowsers'] = uniqueBrowsers.map(&:upcase).sort.join(',')

  # Статистика по пользователям
  users_objects = []

  users.each do |user|
    attributes = user
    user_sessions = sessions[user['id']]
    user_object = User.new(attributes: attributes, sessions: user_sessions)
    users_objects = users_objects + [user_object]
  end

  report['usersStats'] = {}

  collect_stats_from_users(report, users_objects) do |user|
    # not an optimization, just a little refactor to make it more readable
    # at least there is no performance regression
    sessions_times = user.sessions.map { |s| s['time'].to_i }
    session_browsers = user.sessions.map { |s| s['browser'].upcase }

    {
      'sessionsCount' => user.sessions.count,
      'totalTime' => sessions_times.sum.to_s + ' min.',
      'longestSession' => sessions_times.max.to_s + ' min.',
      'browsers' => session_browsers.sort.join(', '),
      'usedIE' => session_browsers.any? { |b| b =~ /INTERNET EXPLORER/ },
      'alwaysUsedChrome' => session_browsers.all? { |b| b =~ /CHROME/ },
      'dates' => user.sessions.map{ |s| s['date'] }.sort.reverse
    }
  end

  report
end

def collect_stats_from_users(report, users_objects, &block)
  users_objects.each do |user|
    user_key = "#{user.attributes['first_name']}" + ' ' + "#{user.attributes['last_name']}"
    report['usersStats'][user_key] ||= {}
    report['usersStats'][user_key] = report['usersStats'][user_key].merge(block.call(user))
  end
end


def get_file_lines(path)
  IO.readlines(path)
end

def measure(profile_name = "report_#{Time.now.to_i}")
  RubyProf.measure_mode = RubyProf::WALL_TIME
  result = RubyProf.profile do
    yield
  end
  printer = RubyProf::CallTreePrinter.new(result)
  printer.print(profile: profile_name)
end

class CorrectnessTest < Minitest::Test
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
    work

    expected_result = '{"totalUsers":3,"uniqueBrowsersCount":14,"totalSessions":15,"allBrowsers":"CHROME 13,CHROME 20,CHROME 35,CHROME 6,FIREFOX 12,FIREFOX 32,FIREFOX 47,INTERNET EXPLORER 10,INTERNET EXPLORER 28,INTERNET EXPLORER 35,SAFARI 17,SAFARI 29,SAFARI 39,SAFARI 49","usersStats":{"Leida Cira":{"sessionsCount":6,"totalTime":"455 min.","longestSession":"118 min.","browsers":"FIREFOX 12, INTERNET EXPLORER 28, INTERNET EXPLORER 28, INTERNET EXPLORER 35, SAFARI 29, SAFARI 39","usedIE":true,"alwaysUsedChrome":false,"dates":["2017-09-27","2017-03-28","2017-02-27","2016-10-23","2016-09-15","2016-09-01"]},"Palmer Katrina":{"sessionsCount":5,"totalTime":"218 min.","longestSession":"116 min.","browsers":"CHROME 13, CHROME 6, FIREFOX 32, INTERNET EXPLORER 10, SAFARI 17","usedIE":true,"alwaysUsedChrome":false,"dates":["2017-04-29","2016-12-28","2016-12-20","2016-11-11","2016-10-21"]},"Gregory Santos":{"sessionsCount":4,"totalTime":"192 min.","longestSession":"85 min.","browsers":"CHROME 20, CHROME 35, FIREFOX 47, SAFARI 49","usedIE":false,"alwaysUsedChrome":false,"dates":["2018-09-21","2018-02-02","2017-05-22","2016-11-25"]}}}' + "\n"
    assert_equal expected_result, File.read('result.json')
  end
end

class PerformanceTest < Minitest::Test
  def setup
    `head -n 10000 data_large.txt > data_perf.txt`
  end

  def test_result
    file_path = 'data_perf.txt'
    start_time = 0.06
    target_time = 0.06

    real_times = []
    10.times do
      GC.disable

      time = Benchmark.measure do
        work(file_path)
      end

      real_times << time.real

      GC.enable
      GC.start
    end

    slowest_sample = real_times.max

    puts "The slowest run: #{slowest_sample}"
    assert(slowest_sample <= start_time)
    assert(slowest_sample <= target_time)
  end
end

#time = Benchmark.measure do
#  work('data_50k')
#end
#
#puts "The large dataset processed in: #{time}"
#
# measure { work('data_50k') }
