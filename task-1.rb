# Deoptimized version of homework task

require 'json'
require 'pry'
require 'date'
require 'minitest/autorun'
require 'benchmark'
require 'ruby-progressbar'

require 'ruby-prof'
require 'stackprof'

# FILE_NAME = 'data_large.txt'
# FILE_NAME = 'data_small.txt'
FILE_NAME = 'data.txt'


class User
  attr_reader :attributes, :sessions

  def initialize(attributes:, sessions:)
    @attributes = attributes
    @sessions = sessions
  end
end

def parse_data(line, result)
  fields = line.split(',')

  if fields[0] == 'user'
    id = fields[1]

    result[id] = {
      first_name: fields[2],
      last_name: fields[3],
      age: fields[4],
      sessions: {}
    }

    return result
  end

  user_id = fields[1]
  session_id = fields[2]

  user = result[user_id]

  sessions = user[:sessions]

  sessions[session_id] = {
    browser: fields[3],
    time: fields[4],
    date: fields[5]
  }

  result
end

def collect_stats_from_users(report, users_objects, &block)
  users_objects.each do |user|
    user_key = "#{user.attributes[:first_name]}" + ' ' + "#{user.attributes[:last_name]}"
    report['usersStats'][user_key] ||= {}
    report['usersStats'][user_key] = report['usersStats'][user_key].merge(block.call(user))
  end
end

def progress_bar(parts_of_work)
  ProgressBar.create(
    total: parts_of_work,
    format: '%a, %J, %E %B' # elapsed time, percent complete, estimate, bar
  # output: File.open(File::NULL, 'w') # IN TEST ENV
  )
end

def work(disable_gc: false, enable_pb: false)
  GC.disable if disable_gc

  file_lines = File.read(FILE_NAME).split("\n")

  progressbar = progress_bar(file_lines.count)

  users = {}

  file_lines.each do |line|
    progressbar.increment if enable_pb
    users = parse_data(line, users)
  end

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

  report = {}

  report[:totalUsers] = users.count

  # Подсчёт количества уникальных браузеров
  unique_browsers = users.values.flat_map do |user|
    user[:sessions].values.flat_map { |session| session[:browser] }
  end.uniq

  report['uniqueBrowsersCount'] = unique_browsers.count

  report['totalSessions'] = users.values.sum { |user| user[:sessions].size }

  all_browsers = users.values.flat_map do |user|
    user[:sessions].values.map { |session| session[:browser].upcase }
  end.sort.uniq.join(',')

  report['allBrowsers'] = all_browsers

  # Статистика по пользователям
  users_objects = []

  users.each_value do |user|
    sessions = user.delete(:sessions)

    user_object = User.new(attributes: user, sessions: sessions)

    users_objects.append(user_object)
  end

  report['usersStats'] = {}

  # Собираем количество сессий по пользователям
  collect_stats_from_users(report, users_objects) do |user|
    { 'sessionsCount' => user.sessions.count }
  end

  # Собираем количество времени по пользователям
  collect_stats_from_users(report, users_objects) do |user|
    { 'totalTime' => user.sessions.values.map {|s| s[:time]}.map {|t| t.to_i}.sum.to_s + ' min.' }
  end

  # Выбираем самую длинную сессию пользователя
  collect_stats_from_users(report, users_objects) do |user|
    { 'longestSession' => user.sessions.values.map {|s| s[:time]}.map {|t| t.to_i}.max.to_s + ' min.' }
  end

  # Браузеры пользователя через запятую
  collect_stats_from_users(report, users_objects) do |user|
    { 'browsers' => user.sessions.values.map {|s| s[:browser]}.map {|b| b.upcase}.sort.join(', ') }
  end

  # Хоть раз использовал IE?
  collect_stats_from_users(report, users_objects) do |user|
    { 'usedIE' => user.sessions.values.map{|s| s[:browser]}.any? { |b| b.upcase =~ /INTERNET EXPLORER/ } }
  end

  # Всегда использовал только Chrome?
  collect_stats_from_users(report, users_objects) do |user|
    { 'alwaysUsedChrome' => user.sessions.values.map{|s| s[:browser]}.all? { |b| b.upcase =~ /CHROME/ } }
  end

  # Даты сессий через запятую в обратном порядке в формате iso8601
  collect_stats_from_users(report, users_objects) do |user|
    { 'dates' => user.sessions.values.map{|s| s[:date]}.map {|d| Date.parse(d)}.sort.reverse.map { |d| d.iso8601 } }
  end

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
    elapsed_time = Benchmark.realtime { work }

    available_time = 2

    msg = "Execution time exceeded: #{elapsed_time} seconds.
           The available time to complete the test is #{available_time} seconds."

    assert elapsed_time <= available_time, msg

    # assert_equal File.read('data.json'), File.read('result.json')

    expected_result = '{"totalUsers":3,"uniqueBrowsersCount":14,"totalSessions":15,"allBrowsers":"CHROME 13,CHROME 20,CHROME 35,CHROME 6,FIREFOX 12,FIREFOX 32,FIREFOX 47,INTERNET EXPLORER 10,INTERNET EXPLORER 28,INTERNET EXPLORER 35,SAFARI 17,SAFARI 29,SAFARI 39,SAFARI 49","usersStats":{"Leida Cira":{"sessionsCount":6,"totalTime":"455 min.","longestSession":"118 min.","browsers":"FIREFOX 12, INTERNET EXPLORER 28, INTERNET EXPLORER 28, INTERNET EXPLORER 35, SAFARI 29, SAFARI 39","usedIE":true,"alwaysUsedChrome":false,"dates":["2017-09-27","2017-03-28","2017-02-27","2016-10-23","2016-09-15","2016-09-01"]},"Palmer Katrina":{"sessionsCount":5,"totalTime":"218 min.","longestSession":"116 min.","browsers":"CHROME 13, CHROME 6, FIREFOX 32, INTERNET EXPLORER 10, SAFARI 17","usedIE":true,"alwaysUsedChrome":false,"dates":["2017-04-29","2016-12-28","2016-12-20","2016-11-11","2016-10-21"]},"Gregory Santos":{"sessionsCount":4,"totalTime":"192 min.","longestSession":"85 min.","browsers":"CHROME 20, CHROME 35, FIREFOX 47, SAFARI 49","usedIE":false,"alwaysUsedChrome":false,"dates":["2018-09-21","2018-02-02","2017-05-22","2016-11-25"]}}}' + "\n"

    assert_equal expected_result, File.read('result.json')
  end

  def test_profile
    result = RubyProf.profile { work(disable_gc: true, enable_pb: true) }

    printer = RubyProf::GraphHtmlPrinter.new(result)
    printer.print(File.open("ruby_prof_reports/graph.html", "w+"))
  end

  # def test_stackprof
  #   profile = StackProf.run(mode: :wall, raw: true) do
  #     work(disable_gc: true)
  #   end
  #
  #   File.write('stackprof_reports/stackprof.json', JSON.generate(profile))
  # end
end
