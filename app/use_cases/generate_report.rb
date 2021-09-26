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

    # file_lines = File.foreach(path).first(64000).join
    # File.write('spec/support/fixtures/data_64000.txt', file_lines)

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
      'age' => fields[4],
    }
  end

  def parse_session(session)
    fields = session.split(',')
    parsed_result = {
      'user_id' => fields[1],
      'session_id' => fields[2],
      'browser' => fields[3],
      'time' => fields[4],
      'date' => fields[5],
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
    # Подсчёт количества уникальных браузеров
    uniqueBrowsers = []
    @sessions.each_slice(BANCH_SIZE) do |sessions|
      sessions.each do |session|
        browser = session['browser']
        uniqueBrowsers += [browser] if uniqueBrowsers.all? { |b| b != browser }
      end
    end
    uniqueBrowsers
  end

  def all_browsers
    @sessions.map { |s| s['browser'] }.map { |b| b.upcase }.sort.uniq.join(',')
  end

  def fill_users_stats(report)
    # Статистика по пользователям
    users_objects = []

    sessions_by_user = @sessions.group_by { |s| s['user_id']}

    @users.each_slice(BANCH_SIZE) do |users|
      users.each do |user|
        attributes = user
        user_sessions = sessions_by_user[user['id']]
        user_object = User.new(attributes: attributes, sessions: user_sessions)
        users_objects = users_objects + [user_object]
      end
    end

    # Собираем количество сессий по пользователям
    collect_stats_from_users(report, users_objects) do |user|
      { 'sessionsCount' => user.sessions.count }
    end
  
    # Собираем количество времени по пользователям
    collect_stats_from_users(report, users_objects) do |user|
      { 'totalTime' => user.sessions.map {|s| s['time']}.map {|t| t.to_i}.sum.to_s + ' min.' }
    end
  
    # Выбираем самую длинную сессию пользователя
    collect_stats_from_users(report, users_objects) do |user|
      { 'longestSession' => user.sessions.map {|s| s['time']}.map {|t| t.to_i}.max.to_s + ' min.' }
    end
  
    # Браузеры пользователя через запятую
    collect_stats_from_users(report, users_objects) do |user|
      { 'browsers' => user.sessions.map {|s| s['browser']}.map {|b| b.upcase}.sort.join(', ') }
    end
  
    # Хоть раз использовал IE?
    collect_stats_from_users(report, users_objects) do |user|
      { 'usedIE' => user.sessions.map{|s| s['browser']}.any? { |b| b.upcase =~ /INTERNET EXPLORER/ } }
    end
  
    # Всегда использовал только Chrome?
    collect_stats_from_users(report, users_objects) do |user|
      { 'alwaysUsedChrome' => user.sessions.map{|s| s['browser']}.all? { |b| b.upcase =~ /CHROME/ } }
    end
  
    # Даты сессий через запятую в обратном порядке в формате iso8601
    collect_stats_from_users(report, users_objects) do |user|
      { 'dates' => user.sessions.map{|s| s['date']}.map {|d| Date.parse(d)}.sort.reverse.map { |d| d.iso8601 } }
    end
  end

  def collect_stats_from_users(report, users_objects, &block)
    users_objects.each_slice(BANCH_SIZE) do |users|
      users.each do |user|
        user_key = "#{user.attributes['first_name']}" + ' ' + "#{user.attributes['last_name']}"
        report['usersStats'][user_key] ||= {}
        report['usersStats'][user_key] = report['usersStats'][user_key].merge(block.call(user))
      end
    end
  end
end
