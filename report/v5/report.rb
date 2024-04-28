# frozen_string_literal: true

module V5
  module_function

  def collect_stats_from_users(report, users_objects)
    users_objects.each do |user|
      user_key = "#{user[:attributes]['first_name']} #{user[:attributes]['last_name']}"

      report['usersStats'][user_key] ||= {}

      block_stat = yield user

      report['usersStats'][user_key][block_stat[0]] = block_stat[1]
    end
  end

  def self.report(users, sessions, sessions_hash, sessions_br)
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
    uniqueBrowsers = sessions_br.keys

    report['uniqueBrowsersCount'] = uniqueBrowsers.count

    report['totalSessions'] = sessions.count

    report['allBrowsers'] = uniqueBrowsers.sort.join(',')

    # Статистика по пользователям
    users_objects = []

    users.each do |user|
      attributes = user
      user_sessions = sessions_hash[user['id']]
      user_object = { attributes:, sessions: user_sessions }
      users_objects.concat([user_object])
    end

    report['usersStats'] = {}

    # Собираем количество сессий по пользователям
    collect_stats_from_users(report, users_objects) do |user|
      ['sessionsCount', user[:sessions].count]
    end

    # Собираем количество времени по пользователям
    collect_stats_from_users(report, users_objects) do |user|
      ['totalTime', user[:sessions].map { |s| s['time'].to_i }.sum.to_s + ' min.']
    end

    # Выбираем самую длинную сессию пользователя
    collect_stats_from_users(report, users_objects) do |user|
      ['longestSession', user[:sessions].map { |s| s['time'].to_i }.max.to_s + ' min.']
    end

    # Браузеры пользователя через запятую
    collect_stats_from_users(report, users_objects) do |user|
      ['browsers', user[:sessions].map { |s| s['browser'] }.sort.join(', ')]
    end

    # Хоть раз использовал IE?
    collect_stats_from_users(report, users_objects) do |user|
      isIE = false

      user[:sessions].each do |s|
        break isIE = true if (s['browser'] =~ /INTERNET EXPLORER/).zero?
      end

      ['usedIE', isIE]
    end

    # Всегда использовал только Chrome?
    collect_stats_from_users(report, users_objects) do |user|
      ['alwaysUsedChrome', user[:sessions].map { |s| s['browser'] }.all? { |b| b =~ /CHROME/ }]
    end

    # Даты сессий через запятую в обратном порядке в формате iso8601
    collect_stats_from_users(report, users_objects) do |user|
      ['dates', user[:sessions].map { |s| s['date'] }.sort.reverse]
    end

    report
  end
end
