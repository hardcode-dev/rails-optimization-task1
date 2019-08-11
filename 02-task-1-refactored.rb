# Deoptimized version of homework task

require 'json'
require 'pry'
require 'date'
require 'set'
require 'ruby-progressbar'
require 'oj'

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

  def parse_session(fields)
    {
     'session_id' => fields[2],
     'browser' => fields[3],
     'time' => fields[4],
     'date' => fields[5],
    }
  end

  def work(file_name, progress_bar = false)
    file_lines = File.read(file_name).split("\n")

    users = []


    count = file_lines.count

    if progress_bar
      puts ">>> processing file lines... "
      progressbar = ProgressBar.create(
          total: count,
          format: '%a, %J, %E %B'
      )
    end

    i = 0
    while i < count
      line = file_lines[i]
      cols = line.split(',')
      if cols[0] == 'session'
        @total_sessions_count += 1
        @unique_browsers.add(cols[3])
        users.last.sessions << parse_session(cols)
      else
        users << User.new(attributes: parse_user(cols), sessions: [])
      end
      i += 1
      progressbar.increment if progress_bar
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

    count = users.count

    if progress_bar
      puts ">>> processing users... "
      progressbar2 = ProgressBar.create(
          total: count,
          format: '%a, %J, %E %B'
      )
    end

    i = 0
    while i < count
      user = users[i]

      user_key = "#{user.attributes['first_name']}" + ' ' + "#{user.attributes['last_name']}"
      user_sessions = user.sessions
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

      i += 1
      progressbar2.increment if progress_bar
    end

    File.write('result.json', "#{Oj.to_json(report)}\n")
  end
end
