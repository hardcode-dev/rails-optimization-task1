require_relative './user'
require 'date'
require 'json'

class Worker
  def initialize(file_path)
    @file_path = file_path
    @users = {}

    @unique_browsers = []
    @sessions_count = 0
  end

  def run
    parsing_file
    report_build
  end

  private

  def report_build
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
    report[:totalUsers] = @users.count
    report['uniqueBrowsersCount'] = @unique_browsers.count
    report['totalSessions'] = @sessions_count
    report['allBrowsers'] = @unique_browsers
    report['usersStats'] = {}

    @users.each do |_user_id, user|
      report['usersStats'][user.key] ||= {
        sessionsCount: user.sessions_count,
        totalTime: user.total_time,
        longestSession: user.longest_session,
        browsers: user.browsers.sort.join(', '),
        usedIE: user.used_ie?,
        alwaysUsedChrome: user.used_only_chrome?,
        dates: user.last_session_dates,
      }
    end

    File.write('result.json', "#{report.to_json}\n")
  end

  def parsing_file
    file_lines = File.read(@file_path).split("\n")

    file_lines.each do |line|
      cols = line.split(',')

      @users[cols[1]] ||= User.new(cols[1])

      if cols[0] == 'session'
        @sessions_count += 1
        session = parse_session(cols)
        @users[cols[1]].add_session(session)
        @unique_browsers << session['browser'] unless @unique_browsers.include?(session['browser'])
      elsif cols[0] == 'user'
        @users[cols[1]].set_info(parse_user(cols))
      end
    end
  end

  def parse_user(user)
    {
      'id' => user[1],
      'first_name' => user[2],
      'last_name' => user[3],
      'age' => user[4],
    }
  end

  def parse_session(session)
    {
      'user_id' => session[1],
      'session_id' => session[2],
      'browser' => session[3].upcase,
      'time' => session[4],
      'date' => session[5],
    }
  end
end
