# Optimized version of homework task

require 'json'
require 'pry'
require 'date'
require 'minitest'
require 'minitest/autorun' if ENV['RACK_ENV'] == 'test'
require 'minitest/benchmark' if ENV['RACK_ENV'] == 'test'
require 'ruby-prof' if ENV['RACK_ENV'] == 'benchmark'
require 'stackprof' if ENV['RACK_ENV'] == 'benchmark'
require 'set'
require 'oj'

def work
  t0 = Time.now
  file_name = 'data_large.txt'
  file_name = 'data.txt' if ENV['RACK_ENV'] == 'test'
  file_lines = File.read(file_name).split("\n")

  users_names_by_id = {}
  sessions_by_user_id = {}
  browsers = Set.new
  sessions_count = 0

  # user_record:
  # 0 - type
  # 1 - id
  # 2 - first_name
  # 3 - last_name
  # 4 - age

  # session_record:
  # 0 - type
  # 1 - user_id
  # 2 - session_id
  # 3 - browser
  # 4 - time
  # 5 - date

  file_lines.each do |line|
    cols = line.split(',')
    if cols[0] == 'user'
      users_names_by_id[cols[1].to_i] = "#{cols[2]} #{cols[3]}"
    elsif cols[0] == 'session'
      sessions_count += 1

      browsers.add(cols[3]) 

      sessions_by_user_id[cols[1].to_i] ||= []
      sessions_by_user_id[cols[1].to_i] << cols
    end
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

  report[:totalUsers] = sessions_by_user_id.count

  # Подсчёт количества уникальных браузеров
  report['uniqueBrowsersCount'] = browsers.count

  report['totalSessions'] = sessions_count

  report['allBrowsers'] =
    browsers
      .map { |b| b.upcase }
      .sort
      .join(',')

  # Статистика по пользователям
  report['usersStats'] = {}

  sessions_by_user_id.each do |user_id, user_sessions|

    user_key = users_names_by_id[user_id]

    sessions_times = user_sessions.map { |s| s[4].to_i }
    user_browsers = user_sessions.map { |s| s[3].upcase }
    user_dates = user_sessions.map { |s| s[5] }

    report['usersStats'][user_key] = {
      # Собираем количество сессий по пользователям
      'sessionsCount' => user_sessions.count,

      # Собираем количество времени по пользователям
      'totalTime' => "#{sessions_times.sum} min.",

      # Выбираем самую длинную сессию пользователя
      'longestSession' => "#{sessions_times.max} min.",

      # Браузеры пользователя через запятую
      'browsers' => user_browsers.sort.join(', '),

      # Хоть раз использовал IE?
      'usedIE' => user_browsers.any? { |b| b =~ /INTERNET EXPLORER/ },

      # Всегда использовал только Chrome?
      'alwaysUsedChrome' => user_browsers.all? { |b| b =~ /CHROME/ },

      # Даты сессий через запятую в обратном порядке в формате iso8601
      'dates' => user_dates.sort.reverse
    }
  end

  File.write('result.json', "#{Oj.to_json(report, mode: :compat)}\n")

  puts "total: #{Time.now - t0}"
end

if ENV['RACK_ENV'] == 'test'
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
      work
      expected_result = '{"totalUsers":3,"uniqueBrowsersCount":14,"totalSessions":15,"allBrowsers":"CHROME 13,CHROME 20,CHROME 35,CHROME 6,FIREFOX 12,FIREFOX 32,FIREFOX 47,INTERNET EXPLORER 10,INTERNET EXPLORER 28,INTERNET EXPLORER 35,SAFARI 17,SAFARI 29,SAFARI 39,SAFARI 49","usersStats":{"Leida Cira":{"sessionsCount":6,"totalTime":"455 min.","longestSession":"118 min.","browsers":"FIREFOX 12, INTERNET EXPLORER 28, INTERNET EXPLORER 28, INTERNET EXPLORER 35, SAFARI 29, SAFARI 39","usedIE":true,"alwaysUsedChrome":false,"dates":["2017-09-27","2017-03-28","2017-02-27","2016-10-23","2016-09-15","2016-09-01"]},"Palmer Katrina":{"sessionsCount":5,"totalTime":"218 min.","longestSession":"116 min.","browsers":"CHROME 13, CHROME 6, FIREFOX 32, INTERNET EXPLORER 10, SAFARI 17","usedIE":true,"alwaysUsedChrome":false,"dates":["2017-04-29","2016-12-28","2016-12-20","2016-11-11","2016-10-21"]},"Gregory Santos":{"sessionsCount":4,"totalTime":"192 min.","longestSession":"85 min.","browsers":"CHROME 20, CHROME 35, FIREFOX 47, SAFARI 49","usedIE":false,"alwaysUsedChrome":false,"dates":["2018-09-21","2018-02-02","2017-05-22","2016-11-25"]}}}' + "\n"
      assert_equal expected_result, File.read('result.json')
    end
  end
elsif ENV['RACK_ENV'] == 'benchmark'
  result = RubyProf.profile do
    work
  end
  printer = RubyProf::FlatPrinter.new(result)
  printer.print(File.open('ruby_prof_reports/flat.txt', 'w+'))

  printer = RubyProf::GraphHtmlPrinter.new(result)
  printer.print(File.open('ruby_prof_reports/graph.html', 'w+'))

  printer = RubyProf::CallStackPrinter.new(result)
  printer.print(File.open('ruby_prof_reports/callstack.html', 'w+'))

  printer = RubyProf::CallTreePrinter.new(result)
  printer.print(path: 'ruby_prof_reports', profile: 'callgrind')

  StackProf.run(mode: :wall, out: 'stackprof_reports/stackprof.dump', interval: 1000) do
    work
  end

  profile = StackProf.run(mode: :wall, raw: true) do
    work
  end
  File.write('stackprof_reports/stackprof.json', JSON.generate(profile))
else
  work
end
