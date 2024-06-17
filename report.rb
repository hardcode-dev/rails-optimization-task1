require 'ruby-progressbar'
require 'set'
require 'date'
require 'json'

class Report
  def initialize(file_name)
    @file_name = file_name
  end

  def to_h
    return @to_h if defined?(@_to_h)

    file_lines = File.read(file_name).split("\n")

    users = {}

    unique_browsers = Set[]
    total_sessions = 0

    progressbar = ProgressBar.create(total: file_lines.count)

    file_lines.each do |line|
      cols = line.split(',')
      if cols[0] == 'user'
        users[cols[1]] = users[cols[1]].to_h.merge(parse_user(cols))
      end
      if cols[0] == 'session'
        users[cols[1]] ||= { 'sessions' => [] }
        session = parse_session(cols)
        users[cols[1]]['sessions'] << session
        unique_browsers << session['browser'].upcase
        total_sessions += 1
      end
      progressbar.increment
    end

    report = {
      'totalUsers' => users.count,
      'uniqueBrowsersCount' => unique_browsers.count,
      'totalSessions' => total_sessions,
      'allBrowsers' => unique_browsers.sort.join(','),
      'usersStats' => {}
    }

    # Собираем количество сессий по пользователям
    collect_stats_from_users(report, users) do |user|
      browsers = user['sessions'].map { |s| s['browser'] }
      times = user['sessions'].map { |s| s['time'].to_i }
      {
        'sessionsCount' => user['sessions'].count,
        'totalTime' => times.sum.to_s + ' min.',
        'longestSession' => times.max.to_s + ' min.',
        'browsers' => browsers.map { |b| b.upcase }.sort.join(', '),
        'usedIE' => browsers.any? { |b| b.upcase =~ /INTERNET EXPLORER/ },
        'alwaysUsedChrome' => browsers.all? { |b| b.upcase =~ /CHROME/ },
        'dates' => user['sessions'].map { |s| s['date'] }.map { |d| Date.new(*d.split('-').map(&:to_i)) }.sort.reverse.map { |d| d.iso8601 },
      }
    end

    report.to_h
  end

  def to_json
    to_h.to_json
  end

  private

  attr_reader :file_name

  def parse_user(fields)
    {
      'id' => fields[1],
      'first_name' => fields[2],
      'last_name' => fields[3],
      'age' => fields[4],
      'sessions' => []
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

  def collect_stats_from_users(report, users_objects)
    users_objects.each do |_, user|
      user_key = "#{user['first_name']}" + ' ' + "#{user['last_name']}"
      report['usersStats'][user_key] ||= {}
      report['usersStats'][user_key] = report['usersStats'][user_key].merge(yield user)
    end
  end
end
