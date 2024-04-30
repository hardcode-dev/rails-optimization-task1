# Deoptimized version of homework task

require 'json'
require 'pry'
require 'date'
require 'set'
require 'minitest'
# require 'minitest/autorun'
require 'ruby-progressbar'

class User
  attr_reader :attributes

  def initialize(attributes:)
    @attributes = attributes
  end
end

def parse_user(fields)
  id, first_name, last_name, age = *fields
  parsed_result = {
    'id' => id,
    'first_name' => first_name,
    'last_name' => last_name,
    'age' => age,
  }
end

def parse_session(fields)
  user_id, session_id, browser, time, date = *fields
  parsed_result = {
    'user_id' => user_id,
    'session_id' => session_id,
    'browser' => browser.upcase,
    'time' => Integer(time),
    'date' => date,
  }
end

def collect_stats_from_users(report, users_objects, &block)
  users_objects.each do |user|
    user_key = "#{user.attributes['first_name']}" + ' ' + "#{user.attributes['last_name']}"
    report['usersStats'][user_key] ||= {}
    report['usersStats'][user_key] = report['usersStats'][user_key].merge(block.call(user))
  end
end

def work(filename)
  users_objects = []
  sessions = []
  browsers = Set.new
  browsers_by_user_id = Hash.new { |h, k| h[k] = [] }

  parsing_progressbar = ProgressBar.create(
    total: `wc -l #{filename}`.to_i,
    format: '%a, %J %E, %B', # elapsed time, percent complete, estimate, bar
    # output: File.open(File::NULL, 'w') #for specs
  )

  File.readlines(filename, chomp: true).each do |line|
    parsing_progressbar.increment
    type, *splitted_line = *line.split(',')

    case type
    when 'user'
      user_attributes = parse_user(splitted_line)
      users_objects << User.new(attributes: user_attributes)
    when 'session'
      s = parse_session(splitted_line)

      sessions = sessions << s
      browsers.add(s['browser'])
      browsers_by_user_id[s['user_id']] << s['browser']
    end
  end

  browsers = browsers.to_a.sort
  sessions_by_users = sessions.group_by { |session| session['user_id'] }

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

  report[:totalUsers] = users_objects.count

  report['uniqueBrowsersCount'] = browsers.count

  report['totalSessions'] = sessions.count

  report['allBrowsers'] = browsers.join(",")

  report['usersStats'] = {}

  handing_progressbar = ProgressBar.create(
    total: users_objects.count-1,
    format: '%a, %J %E, %B', # elapsed time, percent complete, estimate, bar
    # output: File.open(File::NULL, 'w') #for specs
  )

  collect_stats_from_users(report, users_objects) do |user|
    handing_progressbar.increment
    user_browsers = browsers_by_user_id[ user.attributes['id'] ].sort
    uniq_user_browsers = user_browsers.uniq

    user_sessions = sessions_by_users[ user.attributes['id'] ]

    # Собираем количество сессий по пользователям
    sessionsCount = user_sessions.count

    # Собираем количество времени по пользователям
    totalTime = user_sessions.sum {|s| s['time']}.to_s + ' min.'

    # Выбираем самую длинную сессию пользователя
    longestSession = (user_sessions.map {|s| s['time']} || {}).max.to_s + ' min.'

    # Браузеры пользователя через запятую
    browsers = user_browsers.join(', ')

    # Хоть раз использовал IE?
    usedIE = uniq_user_browsers.any? { |b| b =~ /INTERNET EXPLORER/ }

    # Всегда использовал только Chrome?
    user_always_use_chrome = uniq_user_browsers.size == 1 && user_browsers.first.match?(/CHROME/)

    alwaysUsedChrome = user_always_use_chrome

    # Даты сессий через запятую в обратном порядке в формате iso8601
    dates = user_sessions.map{|s| s['date']}.sort.reverse

    {
      'sessionsCount'    => sessionsCount,
      'totalTime'        => totalTime,
      'longestSession'   => longestSession,
      'browsers'         => browsers,
      'usedIE'           => usedIE,
      'alwaysUsedChrome' => alwaysUsedChrome,
      'dates'            => dates,
    }
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
    work('data.txt')
    expected_result = '{"totalUsers":3,"uniqueBrowsersCount":14,"totalSessions":15,"allBrowsers":"CHROME 13,CHROME 20,CHROME 35,CHROME 6,FIREFOX 12,FIREFOX 32,FIREFOX 47,INTERNET EXPLORER 10,INTERNET EXPLORER 28,INTERNET EXPLORER 35,SAFARI 17,SAFARI 29,SAFARI 39,SAFARI 49","usersStats":{"Leida Cira":{"sessionsCount":6,"totalTime":"455 min.","longestSession":"118 min.","browsers":"FIREFOX 12, INTERNET EXPLORER 28, INTERNET EXPLORER 28, INTERNET EXPLORER 35, SAFARI 29, SAFARI 39","usedIE":true,"alwaysUsedChrome":false,"dates":["2017-09-27","2017-03-28","2017-02-27","2016-10-23","2016-09-15","2016-09-01"]},"Palmer Katrina":{"sessionsCount":5,"totalTime":"218 min.","longestSession":"116 min.","browsers":"CHROME 13, CHROME 6, FIREFOX 32, INTERNET EXPLORER 10, SAFARI 17","usedIE":true,"alwaysUsedChrome":false,"dates":["2017-04-29","2016-12-28","2016-12-20","2016-11-11","2016-10-21"]},"Gregory Santos":{"sessionsCount":4,"totalTime":"192 min.","longestSession":"85 min.","browsers":"CHROME 20, CHROME 35, FIREFOX 47, SAFARI 49","usedIE":false,"alwaysUsedChrome":false,"dates":["2018-09-21","2018-02-02","2017-05-22","2016-11-25"]}}}' + "\n"
    assert_equal expected_result, File.read('result.json')
  end
end
