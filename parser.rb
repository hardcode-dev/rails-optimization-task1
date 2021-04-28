# Deoptimized version of homework task
require_relative 'user'

require 'json'
# require 'pry'
require 'date'
require 'benchmark'
# require 'byebug'

class Parser
  def initialize(data:, result:, disable_gc: true)
    @data = data
    @result = result
    GC.disable if disable_gc
  end

  def work
    users = []
    sessions = []
    report = {}
    users_objects = []

    File.foreach(@data).each do |line|
      cols = line.split(',')

      case cols[0]
      when 'user'
        users << parse_user(cols)
      when 'session'
        sessions << parse_session(cols)
      else
        # type code here
      end
    end

    unique_browsers = sessions.map do |session|
      session['browser']
    end.uniq

    sessions_by_user_id ||= sessions.group_by { |session| session['user_id'] }

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

    report['totalUsers'] = users.count
    report['uniqueBrowsersCount'] = unique_browsers.count
    report['totalSessions'] = sessions.count
    report['allBrowsers'] = unique_browsers.sort.join(',').upcase
    report['usersStats'] = {}

    # Статистика по пользователям
    users.each do |user|
      user_sessions = sessions_by_user_id[user['id']] || []
      user_object = User.new(attributes: user, sessions: user_sessions)
      users_objects += [user_object]
    end

    collect_stats_from_users(report, users_objects)

    File.write(@result, "#{report.to_json}\n")
  end

  def parse_date(date)
    Date.strptime(date, '%Y-%m-%d').iso8601
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
      'date' => parse_date(fields[5])
    }
  end

  def collect_stats_from_users(report, users_objects)
    users_objects.each do |user|
      user_key = "#{user.attributes['first_name']} #{user.attributes['last_name']}"

      report_by_user_key = report['usersStats'][user_key] ||= {}

      user_sessions = user.sessions

      time_sessions = user_sessions.map { |session| session['time'].to_i }
      browsers_sessions = user_sessions.map { |session| session['browser'].upcase }

      # Собираем количество сессий по пользователям
      report_by_user_key['sessionsCount'] = user.sessions.count

      # Собираем количество времени по пользователям
      report_by_user_key['totalTime'] = time_sessions.sum.to_s + ' min.'

      # Выбираем самую длинную сессию пользователя
      report_by_user_key['longestSession'] = time_sessions.max.to_s + ' min.'

      # # Браузеры пользователя через запятую
      report_by_user_key['browsers'] = browsers_sessions.sort.join(', ')

      # Хоть раз использовал IE?
      report_by_user_key['usedIE'] = browsers_sessions.any? { |b| b =~ /INTERNET EXPLORER/ }

      # Всегда использовал только Chrome?
      report_by_user_key['alwaysUsedChrome'] = browsers_sessions.all? { |b| b =~ /CHROME/ }

      # Даты сессий через запятую в обратном порядке в формате iso8601
      report_by_user_key['dates'] = user_sessions.map { |s| s['date'] }.sort.reverse
    end
  end
end

Parser.new(data: 'data/data3250.txt', result: 'data/result.json', disable_gc: true).work
