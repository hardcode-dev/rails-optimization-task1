# Deoptimized version of homework task

require 'json'
require 'pry'
require 'date'
require 'minitest/autorun'
require 'rspec'
require 'rspec-benchmark'

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
    'id' => fields[1],
    'first_name' => fields[2],
    'last_name' => fields[3],
    'age' => fields[4]
  }
end

def parse_session(session)
  fields = session.split(',')
  {
    'user_id' => fields[1],
    'session_id' => fields[2],
    'browser' => fields[3],
    'time' => fields[4],
    'date' => fields[5]
  }
end

def collect_stats_from_users(report, users_objects)
  users_objects.each do |user|
    user_key = "#{user.attributes['first_name']} #{user.attributes['last_name']}"
    report['usersStats'][user_key] ||= {}
    report['usersStats'][user_key] = report['usersStats'][user_key].merge(yield(user))
  end
end

def work(filename)
  file_lines = File.read(filename).split("\n")

  users = []
  sessions = []

  file_lines.each do |line|
    cols = line.split(',')
    users += [parse_user(line)] if cols[0] == 'user'
    sessions += [parse_session(line)] if cols[0] == 'session'
  end

  report = {}

  report[:totalUsers] = users.count

  unique_browsers = sessions.each_with_object([]) do |session, result|
    browser = session['browser']
    result << browser
    result
  end.uniq

  report['uniqueBrowsersCount'] = unique_browsers.count
  report['totalSessions'] = sessions.count
  report['allBrowsers'] = unique_browsers.map(&:upcase).sort.join(',')

  # Статистика по пользователям
  users_objects = []

  # предварительно проиндексировал
  sessions_index = sessions.each_with_object({}) do |session, index|
    index[session['user_id']] = [] unless index[session['user_id']]
    index[session['user_id']] << session
    index[session['user_id']]
  end
  # O(1)
  users.each do |user|
    attributes = user

    id = user['id']
    user_sessions = sessions_index[id]
    user_object = User.new(attributes: attributes, sessions: user_sessions)
    users_objects += [user_object]
  end

  report['usersStats'] = {}

  collect_stats_from_users(report, users_objects) do |user|
    {
      'sessionsCount' => user.sessions.count, # Собираем количество сессий по пользователям
      'totalTime' => user.sessions.map { |s| s['time'] }.map(&:to_i).sum.to_s + ' min.', # Собираем количество времени по пользователям
      'longestSession' => user.sessions.map { |s| s['time'] }.map(&:to_i).max.to_s + ' min.', # Выбираем самую длинную сессию пользователя
      'browsers' => user.sessions.map { |s| s['browser'] }.map(&:upcase).sort.join(', '), # Браузеры пользователя через запятую
      'usedIE' => user.sessions.map { |s| s['browser'] }.any? { |b| b.upcase.match?(/INTERNET EXPLORER/) }, # Хоть раз использовал IE?
      'alwaysUsedChrome' => user.sessions.map { |s| s['browser'] }.all? { |b| b.upcase.match?(/CHROME/) }, # Всегда использовал только Chrome?
      'dates' => user.sessions.map { |s| s['date'] }.map { |d| Date.parse(d) }.sort.reverse.map(&:iso8601) # Даты сессий через запятую в обратном порядке в формате iso8601
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

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end

describe 'Performance' do
  describe 'linear work' do
    let(:filename) { 'data10000.txt' }
    it 'works under 1 ms' do
      expect do
        work(filename)
      end.to perform_under(390).ms.warmup(2).times.sample(10).times
    end
  end
end
