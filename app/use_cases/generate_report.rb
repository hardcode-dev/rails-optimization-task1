require 'json'
require 'date'

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

class GenerateReport
  BANCH_SIZE = 1_000

  def work(path)  
    @users = []
    @sessions = []

    # file_lines = File.foreach(path).first(128000).join
    # File.write('spec/support/fixtures/data_128000.txt', file_lines)

    fill_users_sessions(path)
    report = prepare_report
 
    File.write('result.json', "#{report.to_json}\n")
  end

  private

  def fill_users_sessions(path)
    file_lines = File.read(path).split("\n")

    file_lines.each_slice(BANCH_SIZE) do |lines|
      grouped_lines = lines.group_by { |l| l[0] }

      grouped_lines['u'].each do |user|
        @users << parse_user(user)
      end

      grouped_lines['s'].each do |session|
        @sessions << parse_session(session)
      end
    end
  end

  def parse_user(user)
    fields = user.split(',')
    parsed_result = {
      'id' => fields[1],
      'first_name' => fields[2],
      'last_name' => fields[3],
      'age' => fields[4]
    }
  end

  def parse_session(session)
    fields = session.split(',')
    parsed_result = {
      'user_id' => fields[1],
      'session_id' => fields[2],
      'browser' => fields[3],
      'time' => fields[4],
      'date' => fields[5]
    }
  end

  def prepare_report
    report = {}
  
    report[:totalUsers] = @users.count
    report['uniqueBrowsersCount'] = uniq_browsers.count  
    report['totalSessions'] = @sessions.count
    report['allBrowsers'] = all_browsers
    report['usersStats'] = {}

    fill_users_stats(report)

    report
  end

  def uniq_browsers
    @uniq_browsers ||= browsers_list
  end

  def browsers_list
    # Подсчёт количества уникальных браузеров
    uniqueBrowsers = []
    @sessions.each_slice(BANCH_SIZE) do |sessions|
      uniqueBrowsers << sessions.map { |session| session['browser'] }.uniq
    end
    uniqueBrowsers.flatten.uniq
  end

  def all_browsers
    uniq_browsers.map { |b| b.upcase }.sort.join(',')
  end

  def fill_users_stats(report)
    # Статистика по пользователям
    sessions_by_user = @sessions.group_by { |s| s['user_id'] }

    process_users_objects(report, sessions_by_user)
  end

  def process_users_objects(report, sessions_by_user)
    @users.each_slice(BANCH_SIZE) do |users|
      users.each do |user|
        attributes = user
        user_key = "#{user['first_name']}" + ' ' + "#{user['last_name']}"
        report['usersStats'][user_key] ||= {}

        sessions = sessions_by_user[user['id']]
        time = sessions.map { |s| s['time'].to_i }
        browsers = sessions.map { |s| s['browser'].upcase }.sort

        report['usersStats'][user_key]['sessionsCount'] = sessions.count
        report['usersStats'][user_key]['totalTime'] = time.sum.to_s + ' min.'
        report['usersStats'][user_key]['longestSession'] = time.max.to_s + ' min.'
        report['usersStats'][user_key]['browsers'] = browsers.join(', ')
        report['usersStats'][user_key]['usedIE'] = browsers.any? { |b| b =~ /INTERNET EXPLORER/ }
        report['usersStats'][user_key]['alwaysUsedChrome'] = browsers.none? { |b| b !~ /CHROME/ }
        report['usersStats'][user_key]['dates'] = sessions.map { |s| s['date'] }.sort! {|a, b| b <=> a}
      end
    end
  end
end
