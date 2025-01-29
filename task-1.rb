# Deoptimized version of homework task

require 'json'
require 'pry'
require 'date'
require 'minitest/autorun'

DEFAULT_FILE = 'files/data.txt'.freeze

def parse_user(fields)
  {
    'id' => fields[1],
    'first_name' => fields[2],
    'last_name' => fields[3],
    'age' => fields[4],
  }
end

def parse_session(sessions, fields)
  _session, user_id, session_id, browser, time, date = fields

  sessions[user_id] ||= {
    'session_ids' => [],
    'browsers' => [],
    'times' => [],
    'dates' => [],
    'total' => 0,
  }
  sessions[user_id]['session_ids'] << session_id
  sessions[user_id]['browsers'] << browser.upcase
  sessions[user_id]['times'] << time.to_i
  sessions[user_id]['dates'] << date
  sessions[user_id]['total'] += 1
end

def collect_stats_from_user(sessions)
  {
    'sessionsCount' => sessions['total'],
    'totalTime' => sessions['times'].sum.to_s + ' min.',
    'longestSession' => sessions['times'].max.to_s + ' min.',
    'browsers' => sessions['browsers'].sort.join(', '),
    'usedIE' => sessions['browsers'].any? { |b| b =~ /INTERNET EXPLORER/ },
    'alwaysUsedChrome' => sessions['browsers'].all? { |b| b =~ /CHROME/ },
    'dates' => sessions['dates'].sort.reverse,
  }
end

def work(filename: '', disable_gc: false)
  GC.disable if disable_gc

  file_name = ENV['DATA_FILE'] || filename || DEFAULT_FILE
  file_lines = File.read(file_name).split("\n")

  users = []
  sessions = {}

  file_lines.each do |line|
    cols = line.split(',')

    users << parse_user(cols) if cols[0] == 'user'
    parse_session(sessions, cols) if cols[0] == 'session'
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

  report['totalUsers'] = users.count

  all_sessions = sessions.values.flatten
  browsers = all_sessions.flat_map { |s| s['browsers'] }.uniq.sort

  report['uniqueBrowsersCount'] = browsers.count

  report['totalSessions'] = all_sessions.flat_map { |s| s['total'] }.sum

  report['allBrowsers'] = browsers.join(',')

  # Статистика по пользователям
  report['usersStats'] = {}

  users.each do |user|
    user_key = "#{user['first_name']} #{user['last_name']}"
    user_sessions = sessions[user['id']]
    
    report['usersStats'][user_key] = collect_stats_from_user(user_sessions)
  end

  File.write('result.json', "#{report.to_json}\n")
end

class TestMe < Minitest::Test
  def setup
    File.write('result.json', '')
    File.write('files/data.txt',
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
    work(filename: 'files/data.txt')
    expected_result = '{"totalUsers":3,"uniqueBrowsersCount":14,"totalSessions":15,"allBrowsers":"CHROME 13,CHROME 20,CHROME 35,CHROME 6,FIREFOX 12,FIREFOX 32,FIREFOX 47,INTERNET EXPLORER 10,INTERNET EXPLORER 28,INTERNET EXPLORER 35,SAFARI 17,SAFARI 29,SAFARI 39,SAFARI 49","usersStats":{"Leida Cira":{"sessionsCount":6,"totalTime":"455 min.","longestSession":"118 min.","browsers":"FIREFOX 12, INTERNET EXPLORER 28, INTERNET EXPLORER 28, INTERNET EXPLORER 35, SAFARI 29, SAFARI 39","usedIE":true,"alwaysUsedChrome":false,"dates":["2017-09-27","2017-03-28","2017-02-27","2016-10-23","2016-09-15","2016-09-01"]},"Palmer Katrina":{"sessionsCount":5,"totalTime":"218 min.","longestSession":"116 min.","browsers":"CHROME 13, CHROME 6, FIREFOX 32, INTERNET EXPLORER 10, SAFARI 17","usedIE":true,"alwaysUsedChrome":false,"dates":["2017-04-29","2016-12-28","2016-12-20","2016-11-11","2016-10-21"]},"Gregory Santos":{"sessionsCount":4,"totalTime":"192 min.","longestSession":"85 min.","browsers":"CHROME 20, CHROME 35, FIREFOX 47, SAFARI 49","usedIE":false,"alwaysUsedChrome":false,"dates":["2018-09-21","2018-02-02","2017-05-22","2016-11-25"]}}}' + "\n"
    assert_equal expected_result, File.read('result.json')
  end
end
