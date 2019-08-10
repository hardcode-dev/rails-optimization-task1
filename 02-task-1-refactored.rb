# Deoptimized version of homework task

require 'json'
require 'pry'
require 'date'
require 'set'
require 'ruby-progressbar'

class Refactored

  def initialize
    @total_sessions_count = 0
    @unique_browsers = Set.new
  end

  def parse_user(fields)
    {
      'id' => fields[1],
      'first_name' => fields[2],
      'last_name' => fields[3],
      'age' => fields[4]
    }
  end

  def parse_session(result, fields)
    @total_sessions_count += 1
    user_id = fields[1]
    browser = fields[3]
    @unique_browsers.add(browser)

    session = {
         'session_id' => fields[2],
         'browser' => browser,
         'time' => fields[4],
         'date' => fields[5],
    }
    result[user_id] = if result[user_id].nil?
                        [session]
                      else
                        result[user_id] + [session]
                      end
    result
  end

  def collect_stats_from_users(report, users_objects, &block)
    users_objects.each do |user|
      user_key = "#{user.attributes['first_name']}" + ' ' + "#{user.attributes['last_name']}"
      report['usersStats'][user_key] ||= {}
    end
  end

  def work(file_name)
    file_lines = File.read(file_name).split("\n")

    users = []
    sessions = {}

    count = file_lines.count
    progressbar = ProgressBar.create(
        total: count,
        format: '%a, %J, %E %B'
    )

    file_lines.each do |line|
      cols = line.split(',')
      users = users + [parse_user(cols)] if cols[0] == 'user'
      sessions = parse_session(sessions, cols) if cols[0] == 'session'

      progressbar.increment
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
    report['uniqueBrowsersCount'] = @unique_browsers.count
    report['totalSessions'] = @total_sessions_count
    report['allBrowsers'] =
        @unique_browsers
            .map { |b| b.upcase }
            .sort
            .join(',')

    # Статистика по пользователям
    report['usersStats'] = {}

    puts "processing users"
    count = users.count
    progressbar2 = ProgressBar.create(
        total: count,
        format: '%a, %J, %E %B'
    )

    users.each do |user|
      user_key = "#{user['first_name']}" + ' ' + "#{user['last_name']}"
      user_sessions = sessions[user['id']]
      user_time = []
      user_browsers = []
      user_dates = []
      user_sessions.each do |one_session|
        user_time.append(one_session['time'].to_i)
        user_browsers.append(one_session['browser'].upcase)
        user_dates.append(one_session['date'])
      end

      report['usersStats'][user_key] ||= {}
      # Собираем количество сессий
      report['usersStats'][user_key]['sessionsCount'] = user_sessions.count
      # Собираем количество времени
      report['usersStats'][user_key]['totalTime'] = user_time.sum.to_s + ' min.'
      # Выбираем самую длинную сессию пользователя
      report['usersStats'][user_key]['longestSession'] = user_time.max.to_s + ' min.'
      # Браузеры пользователя через запятую
      report['usersStats'][user_key]['browsers'] = user_browsers.sort.join(', ')
      # Хоть раз использовал IE?
      report['usersStats'][user_key]['usedIE'] = user_browsers.any? { |b| b =~ /INTERNET EXPLORER/ }
      # Всегда использовал только Chrome?
      report['usersStats'][user_key]['alwaysUsedChrome'] = user_browsers.all? { |b| b =~ /CHROME/ }
      # Даты сессий через запятую в обратном порядке в формате iso8601
      report['usersStats'][user_key]['dates'] = user_dates.sort.reverse

      progressbar2.increment
    end

    File.write('result.json', "#{report.to_json}\n")
  end
end
