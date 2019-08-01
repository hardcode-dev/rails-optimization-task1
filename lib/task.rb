class Task
  def initialize(result_file_path: nil, data_file_path: nil, dasable_gc: true)
    GC.disable if dasable_gc
    @result_file_path = result_file_path || 'data/result.json'
    @data_file_path = data_file_path || 'data/data_large.txt'
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

  def collect_stats_from_users(report, users_objects, &block)
    users_objects.each do |user|
      user_key = "#{user.attributes['first_name']}" + ' ' + "#{user.attributes['last_name']}"
      report['usersStats'][user_key] ||= {}
      report['usersStats'][user_key] = report['usersStats'][user_key].merge(block.call(user))
    end
  end

  def work
    file_lines = File.read(data_file_path).split("\n")

    users = []
    sessions = []

    file_lines.each do |line|
      cols = line.split(',')
      users = users + [parse_user(line)] if cols[0] == 'user'
      sessions = sessions + [parse_session(line)] if cols[0] == 'session'
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
    uniqueBrowsers = get_unique_browsers(sessions)
    report['uniqueBrowsersCount'] = uniqueBrowsers.count
    report['totalSessions'] = sessions.count

    report['allBrowsers'] =
      sessions
        .map { |s| s['browser'] }
        .map { |b| b.upcase }
        .sort
        .uniq
        .join(',')

    # Статистика по пользователям
    users_objects = []

    grouped_by_user_id_sessions = sessions.group_by { |session| session['user_id'] }

    users.each do |user|
      user_sessions = grouped_by_user_id_sessions[user['id']]
      user_object = User.new(attributes: user, sessions: user_sessions)
      users_objects = users_objects + [user_object]
    end

    report['usersStats'] = {}

    collect_stats_from_users(report, users_objects) do |user|
      {
        # Собираем количество сессий по пользователям
        'sessionsCount' => user.sessions.count,
        # Собираем количество времени по пользователям
        'totalTime' => user.sessions.map {|s| s['time']}.map {|t| t.to_i}.sum.to_s + ' min.',
        # Выбираем самую длинную сессию пользователя
        'longestSession' => user.sessions.map {|s| s['time']}.map {|t| t.to_i}.max.to_s + ' min.',
        # Браузеры пользователя через запятую
        'browsers' => user.sessions.map {|s| s['browser']}.map {|b| b.upcase}.sort.join(', '),
        # Хоть раз использовал IE?
        'usedIE' => user.sessions.map{|s| s['browser']}.any? { |b| b.upcase =~ /INTERNET EXPLORER/ },
        # Всегда использовал только Chrome?
        'alwaysUsedChrome' => user.sessions.map{|s| s['browser']}.all? { |b| b.upcase =~ /CHROME/ },
        # Даты сессий через запятую в обратном порядке в формате iso8601
        'dates' => user.sessions.map{|s| s['date']}.map {|d| Date.parse(d)}.sort.reverse.map { |d| d.iso8601 }
      }
    end

    File.write(result_file_path, "#{report.to_json}\n")
  end

  private

  attr_reader :result_file_path, :data_file_path

  def get_unique_browsers(sessions)
    store = {}
    sessions.each { |session| store[session['browser']] = 1 }
    store.keys
  end
end
