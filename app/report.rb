class Report
  attr_reader :users, :disable_bar

  def initialize(users, disable_bar)
    @users = users
    @disable_bar = disable_bar
  end

  def call
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
    unique_browsers = users.values.flat_map do |user|
      user[:sessions][:items].values.flat_map { |session| session[:browser] }
    end.compact.uniq

    report['uniqueBrowsersCount'] = unique_browsers.count

    report['totalSessions'] = users.values.sum { |user| user[:sessions].size }

    all_browsers = users.values.flat_map do |user|
      user[:sessions][:items].values.map { |session| session[:browser] }
    end.compact.sort.uniq.join(',')

    report['allBrowsers'] = all_browsers

    # Статистика по пользователям
    users_objects = []

    users.each_value do |user|
      sessions = user.delete(:sessions)

      user_object = User.new(attributes: user, sessions: sessions)

      users_objects.append(user_object)
    end

    report['usersStats'] = {}

    collect_data(report, users_objects)
  end

  def collect_data(report, users_objects)
    bar = Bar.new(users_objects.count).progress unless disable_bar

    report['usersStats'] = {}

    users_objects.each do |user|
      bar.increment unless disable_bar

      user_key = "#{user.attributes[:first_name]} #{user.attributes[:last_name]}"

      report['usersStats'][user_key] ||= {}

      # Собираем количество сессий по пользователям
      report['usersStats'][user_key][:sessionsCount] = user.sessions[:items].count

      # Собираем количество времени по пользователям
      report['usersStats'][user_key][:totalTime] = "#{user.sessions[:total_time]} min."

      # Выбираем самую длинную сессию пользователя
      report['usersStats'][user_key][:longestSession] = "#{user.sessions[:long_session]} min."

      # Браузеры пользователя через запятую
      report['usersStats'][user_key][:browsers] = user.sessions[:browsers].sort.join(', ')

      # Хоть раз использовал IE?
      report['usersStats'][user_key][:usedIE] = user.sessions[:browsers].any? { |b| b =~ /INTERNET EXPLORER/ }

      # Всегда использовал только Chrome?
      report['usersStats'][user_key][:alwaysUsedChrome] = user.sessions[:browsers].all? { |b| b =~ /CHROME/ }

      # Даты сессий через запятую в обратном порядке в формате iso8601
      report['usersStats'][user_key][:dates] = user.sessions[:dates].sort.reverse
    end

    report
  end
end
