# frozen_string_literal: true

require 'json'
require 'date'
require 'set'
require 'benchmark'
require 'ruby-progressbar' if ENV['APP_ENV'] != 'test'

class User
  attr_reader :attributes
  attr_accessor :sessions

  def initialize(attributes)
    @attributes = attributes
    @sessions = []
  end
end

def parse_user(fields)
  {
    'id' => fields[1],
    'first_name' => fields[2],
    'last_name' => fields[3],
    'age' => fields[4]
  }
end

def parse_session(fields)
  {
    'user_id' => fields[1],
    'session_id' => fields[2],
    'browser' => fields[3],
    'time' => fields[4],
    'date' => fields[5]
  }
end

def collect_stats_from_users(user)
  sessions = user.sessions
  times = sessions.map { |s| s['time'].to_i }
  browsers = sessions.map { |s| s['browser'].upcase }.sort
  {
    'sessionsCount' => sessions.count,
    'totalTime' => "#{times.sum} min.",
    'longestSession' => "#{times.max} min.",
    'browsers' => browsers.join(', '),
    'usedIE' => browsers.any? { |s| s =~ /INTERNET EXPLORER/ },
    'alwaysUsedChrome' => browsers.none? { |s| s !~ /CHROME/ },
    'dates' => sessions.map { |s| s['date'] }.sort.reverse
  }
end

def work(filename, disable_gc = false)
  GC.disable if disable_gc

  file_lines = File.read(filename).split("\n")

  if ENV['APP_ENV'] != 'test'
    lines_count = file_lines.size
    progressbar = ProgressBar.create(title: 'Lines', total: lines_count)
  end

  sessions = []
  users_objects = []
  users_hash = {}
  users_count = 0
  sessions_count = 0
  unique_browsers = Set.new
  unique_browsers_count = 0

  file_lines.each do |line|
    cols = line.split(',')
    progressbar.increment if ENV['APP_ENV'] != 'test'

    if cols[0] == 'user'
      users_count += 1
      parsed_user = parse_user(cols)
      user = User.new(parsed_user)
      users_objects << user
      users_hash[parsed_user['id']] = user
    end

    next unless cols[0] == 'session'

    sessions_count += 1
    parsed_session = parse_session(cols)
    users_hash[parsed_session['user_id']].sessions << parsed_session
    sessions << parsed_session
    unique_browsers_count += 1 if unique_browsers.add?(parsed_session['browser'].upcase)
  end

  report = {
    totalUsers: users_count,
    uniqueBrowsersCount: unique_browsers_count,
    totalSessions: sessions_count,
    allBrowsers: unique_browsers.sort.join(','),
    usersStats: {}
  }
  users_objects.each do |u|
    report[:usersStats]["#{u.attributes['first_name']} #{u.attributes['last_name']}"] = collect_stats_from_users(u)
  end

  File.write('result.json', "#{report.to_json}\n")
end

puts(Benchmark.realtime { work(ENV['DATA_FILE'] || 'data.txt') }) if ENV['APP_ENV'] != 'test'
