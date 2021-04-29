# Deoptimized version of homework task

require 'json'
# require 'pry'
require 'date'
# require 'byebug'

class Parser
  def initialize(data:, result:, disable_gc: true)
    @data = data
    @result = result
    GC.disable if disable_gc
  end

  def collect_stats_from_users(report, users)
    users.each do |user|
      user_key = "#{user['first_name']} #{user['last_name']}"
      report['usersStats'][user_key] ||= {}.merge!(yield(user))
    end
  end

  def work
    users = []
    sessions = []
    report = {}

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
    report['allBrowsers'] = unique_browsers.sort.join(',')
    report['usersStats'] = {}

    # Статистика по пользователям
    collect_stats_from_users(report, users) do |user|
      user_sessions = sessions_by_user_id[user['id']] || []
      time_sessions = user_sessions.map { |session| session['time'] }
      browsers_sessions = user_sessions.map { |session| session['browser'] }

      {
        # Собираем количество сессий по пользователям
        'sessionsCount' => user_sessions.count,

        # Собираем количество времени по пользователям
        'totalTime' => "#{time_sessions.sum} min.",

        # Выбираем самую длинную сессию пользователя
        'longestSession' => "#{time_sessions.max} min.",

        # # Браузеры пользователя через запятую
        'browsers' => browsers_sessions.sort.join(', '),

        # Хоть раз использовал IE?
        'usedIE' => browsers_sessions.any? { |b| b.start_with? 'INTERNET EXPLORER' },

        # Всегда использовал только Chrome?
        'alwaysUsedChrome' => browsers_sessions.all? { |b| b.start_with? 'CHROME' },

        # Даты сессий через запятую в обратном порядке в формате iso8601
        'dates' => user_sessions.map { |s| s['date'] }.sort.reverse
      }
    end

    File.write(@result, "#{report.to_json}\n")
  end

  def parse_date(date)
    Date.strptime(date, '%Y-%m-%d').iso8601
  end

  def parse_user(fields)
    {
      'id' => fields[1],
      'first_name' => fields[2],
      'last_name' => fields[3]
    }
  end

  def parse_session(fields)
    {
      'user_id' => fields[1],
      'session_id' => fields[2],
      'browser' => fields[3].upcase,
      'time' => fields[4].to_i,
      'date' => parse_date(fields[5])
    }
  end
end
