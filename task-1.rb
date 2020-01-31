# frozen_string_literal: true

# Deoptimized version of homework task
require "set"
require 'oj'
# require 'pry'
require 'date'
#

#GC.disable

class User
  attr_reader :attributes, :sessions

  def initialize(attributes:, sessions:)
    @attributes = attributes
    @sessions = sessions
  end
end

def parse_user(user)
  fields = user.split(',')

  {
    id: fields[1],
    name: fields[2] + ' ' + fields[3]
  }
end

def parse_session(session)
  fields = session.split(',')

  {
    user_id: fields[1],
    session_id: fields[2],
    browser: fields[3].upcase,
    time: fields[4].to_i,
    date: fields[5]
  }
end


def fill_report_from_user(user, stats)
  user_key = user.attributes[:name]
  stats[user_key] = yield(user)
end

def collect_stats_from_users(stats, users_objects, &block)
  users_objects.each do |user|
    fill_report_from_user(user, stats, &block)
  end
end

def process_line(users, sessions,line)
  cols = line.split(',')
  users << parse_user(line) if cols[0] == 'user'
  sessions << parse_session(line) if cols[0] == 'session'
end

def work
  file_lines = File.read('data_large.txt').split("\n")

  users = []
  sessions = []

  file_lines.each do |line|
    process_line(users, sessions,line)
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

  unique_browsers = SortedSet.new(sessions.map { |s| s[:browser] })
  report['uniqueBrowsersCount'] = unique_browsers.count
  report['totalSessions'] = sessions.count
  report['allBrowsers'] = unique_browsers.to_a.join(',')



  # Статистика по пользователям

  hashed_sessions = sessions.group_by { |session| session[:user_id] }

  users_objects = users.collect do |user|
    attributes = user
    user_sessions = hashed_sessions[user[:id]] || []

    User.new(attributes: attributes, sessions: user_sessions)
  end

  stats = {}


  collect_stats_from_users(stats, users_objects) do |user|

    browsers = user.sessions.map { |s| s[:browser] }.sort.join(', ')
    only_chrome = user.sessions.all? { |b| b[:browser].include?('CHROME') }
    used_ie = only_chrome ? false : browsers.include?('INTERNET EXPLORER')



    {
        'sessionsCount' => user.sessions.count,  # Собираем количество сессий по пользователям
        'totalTime' => user.sessions.sum { |s| s[:time] }.to_s + ' min.', # Собираем количество времени по пользователям
        'longestSession' => user.sessions.max_by { |s| s[:time] }[:time].to_s + ' min.', # Выбираем самую длинную сессию пользователя
        'browsers' => browsers,  # Браузеры пользователя через запятую
        'usedIE' => used_ie, # Хоть раз использовал IE?
        'alwaysUsedChrome' => only_chrome,  # Всегда использовал только Chrome?
        'dates' => user.sessions.map { |s| s[:date] }.sort.reverse  # Даты сессий через запятую в обратном порядке в формате iso8601
    }
  end


  report['usersStats'] = stats
  Oj.mimic_JSON()
  File.write('result.json', Oj.dump(report) + "\n")
end


# require 'minitest/autorun'
#
# class TestMe < Minitest::Test
#   def setup
#     File.write('result.json', '')
#     File.write('data.txt',
# 'user,0,Leida,Cira,0
# session,0,0,Safari 29,87,2016-10-23
# session,0,1,Firefox 12,118,2017-02-27
# session,0,2,Internet Explorer 28,31,2017-03-28
# session,0,3,Internet Explorer 28,109,2016-09-15
# session,0,4,Safari 39,104,2017-09-27
# session,0,5,Internet Explorer 35,6,2016-09-01
# user,1,Palmer,Katrina,65
# session,1,0,Safari 17,12,2016-10-21
# session,1,1,Firefox 32,3,2016-12-20
# session,1,2,Chrome 6,59,2016-11-11
# session,1,3,Internet Explorer 10,28,2017-04-29
# session,1,4,Chrome 13,116,2016-12-28
# user,2,Gregory,Santos,86
# session,2,0,Chrome 35,6,2018-09-21
# session,2,1,Safari 49,85,2017-05-22
# session,2,2,Firefox 47,17,2018-02-02
# session,2,3,Chrome 20,84,2016-11-25
# ')
#   end
#
#   def test_result
#     work
#     expected_result = '{"totalUsers":3,"uniqueBrowsersCount":14,"totalSessions":15,"allBrowsers":"CHROME 13,CHROME 20,CHROME 35,CHROME 6,FIREFOX 12,FIREFOX 32,FIREFOX 47,INTERNET EXPLORER 10,INTERNET EXPLORER 28,INTERNET EXPLORER 35,SAFARI 17,SAFARI 29,SAFARI 39,SAFARI 49","usersStats":{"Leida Cira":{"sessionsCount":6,"totalTime":"455 min.","longestSession":"118 min.","browsers":"FIREFOX 12, INTERNET EXPLORER 28, INTERNET EXPLORER 28, INTERNET EXPLORER 35, SAFARI 29, SAFARI 39","usedIE":true,"alwaysUsedChrome":false,"dates":["2017-09-27","2017-03-28","2017-02-27","2016-10-23","2016-09-15","2016-09-01"]},"Palmer Katrina":{"sessionsCount":5,"totalTime":"218 min.","longestSession":"116 min.","browsers":"CHROME 13, CHROME 6, FIREFOX 32, INTERNET EXPLORER 10, SAFARI 17","usedIE":true,"alwaysUsedChrome":false,"dates":["2017-04-29","2016-12-28","2016-12-20","2016-11-11","2016-10-21"]},"Gregory Santos":{"sessionsCount":4,"totalTime":"192 min.","longestSession":"85 min.","browsers":"CHROME 20, CHROME 35, FIREFOX 47, SAFARI 49","usedIE":false,"alwaysUsedChrome":false,"dates":["2018-09-21","2018-02-02","2017-05-22","2016-11-25"]}}}' + "\n"
#     assert_equal expected_result, File.read('result.json')
#   end
# end
#

#
# def profile
#   require 'ruby-prof'
#   GC.disable
#   result = RubyProf.profile do
#     work
#   end
#
#
# # print a graph profile to text
#   printer = RubyProf::GraphHtmlPrinter.new(result)
#   printer.print(File.open('1.html', 'w'), {})
#
#   printer = RubyProf::CallTreePrinter.new(result)
#
#   printer.print
# end
#
#
# if true
#   profile
# else
   work
# end
