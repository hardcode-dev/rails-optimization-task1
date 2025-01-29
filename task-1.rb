# frozen_string_literal: true

# Deoptimized version of homework task

require 'json'
require 'csv'

class User
  attr_reader :attributes, :sessions

  def initialize(attributes:, sessions:)
    @attributes = attributes
    @sessions   = sessions
  end

  def browsers
    @browsers ||= sessions.map { |s| s[Col::Session::BROWSER].upcase }.sort
  end

  def sessions_time
    @sessions_time ||= sessions.map { |s| s[Col::Session::TIME].to_i }
  end
end

module Col
  module User
    ID         = 1
    FIRST_NAME = 2
    LAST_NAME  = 3
    AGE        = 4
  end

  module Session
    USER_ID    = 1
    SESSION_ID = 2
    BROWSER    = 3
    TIME       = 4
    DATE       = 5
  end
end

def collect_stats_from_users(report, users_objects)
  users_objects.each do |user|
    user_key = "#{user.attributes[Col::User::FIRST_NAME]} #{user.attributes[Col::User::LAST_NAME]}"

    report['usersStats'][user_key] = yield(user)
  end
end

def work(file_name, gc_disable: false)
  return unless file_name

  GC.disable if gc_disable

  file_lines = CSV.read(file_name, headers: false, col_sep: ',')
  users = file_lines.select { |line| line[0] == 'user' }
  sessions = file_lines.select { |line| line[0] == 'session' }

  user_sessions = {}

  sessions.each do |session|
    user_sessions[session[Col::Session::USER_ID]] ||= []
    user_sessions[session[Col::Session::USER_ID]] << session
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

  unique_sessions = sessions.uniq { |session| session[Col::Session::BROWSER] }
  unique_browsers = unique_sessions.map { |session| session[Col::Session::BROWSER] }

  report = {
    'totalUsers'          => users.count,
    'uniqueBrowsersCount' => unique_browsers.count,
    'totalSessions'       => sessions.count,
    'allBrowsers'         => unique_browsers.map(&:upcase).sort.uniq.join(',')
  }

  users_objects = users.map do |user|
    User.new(attributes: user, sessions: user_sessions[user[Col::User::ID]])
  end

  report['usersStats'] = {}

  collect_stats_from_users(report, users_objects) do |user|
    {
      'sessionsCount'    => user.sessions.count,
      'totalTime'        => "#{user.sessions_time.sum} min.",
      'longestSession'   => "#{user.sessions_time.max} min.",
      'browsers'         => user.browsers.join(",\s"),
      'usedIE'           => user.browsers.any? { |b| b.start_with?('INTERNET EXPLORER') },
      'alwaysUsedChrome' => user.browsers.all? { |b| b.start_with?('CHROME') },
      'dates'            => user.sessions.map { |s| s[Col::Session::DATE] }.sort.reverse
    }
  end

  File.write('result.json', "#{report.to_json}\n")
end
