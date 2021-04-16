# Deoptimized version of homework task

require 'json'
require 'pry'
require 'date'
require 'benchmark'
require_relative 'user'

class ParserOptimized
  class << ParserOptimized
    def parse_user(fields)
      {
        'id' => fields[1],
        'first_name' => fields[2],
        'last_name' => fields[3],
        'age' => fields[4],
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

    def collect_stats_from_users(report, users_objects, &block)
      users_objects.each do |user|
        user_key = user.attributes['first_name'].to_s + ' ' + user.attributes['last_name'].to_s
        report['usersStats'][user_key] ||= {}
        report['usersStats'][user_key] = report['usersStats'][user_key].merge(block.call(user))
      end
    end

    def work(filename = 'data_large.txt', gc_disabled: false)
      GC.disable if gc_disabled

      users = []
      sessions = []

      File.foreach(filename) do |line|
        cols = line.split(',')
        users = users + [parse_user(cols)] if cols[0] == 'user'
        sessions = sessions + [parse_session(cols)] if cols[0] == 'session'
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

      # Подсчёт количества уникальных браузеров
      uniqueBrowsers = sessions.map { |session| session['browser'] }.uniq

      report['uniqueBrowsersCount'] = uniqueBrowsers.count

      report['totalSessions'] = sessions.count

      report['allBrowsers'] =
        sessions
          .map { |s| s['browser'].upcase }
          .sort
          .uniq
          .join(',')

      # Статистика по пользователям
      users_objects = []

      sessions_by_user = sessions.group_by { |session| session['user_id'] }

      users.each do |user|
        attributes = user
        user_sessions = sessions_by_user[user['id']] || []
        user_object = User.new(attributes: attributes, sessions: user_sessions)
        users_objects = users_objects + [user_object]
      end

      report['usersStats'] = {}

      collect_stats_from_users(report, users_objects) do |user|
        user_browsers = user.sessions.map { |s| s['browser'].upcase }
        session_times = user.sessions.map { |s| s['time'].to_i }
        {
          # Собираем количество сессий по пользователям
          'sessionsCount' => user.sessions.count,
          # Собираем количество времени по пользователям
          'totalTime' => session_times.sum.to_s + ' min.',
          # Выбираем самую длинную сессию пользователя
          'longestSession' => session_times.max.to_s + ' min.',
          # Браузеры пользователя через запятую
          'browsers' => user_browsers.sort.join(', '),
          # Хоть раз использовал IE?
          'usedIE' => user_browsers.any? { |b| b.start_with? 'INTERNET EXPLORER' },
          # Всегда использовал только Chrome?
          'alwaysUsedChrome' => user_browsers.all? { |b| b.start_with? 'CHROME' },
          # Даты сессий через запятую в обратном порядке в формате iso8601
          'dates' => user.sessions.map { |s| s['date'] }.map { |d| Date.strptime(d, '%Y-%m-%d') }.sort.reverse.map { |d| d.iso8601 }
        }
      end

      File.write('result.json', "#{report.to_json}\n")
    end
  end
end
