# frozen_string_literal: true

module V3
  module_function

  class User
    attr_reader :attributes, :sessions

    def initialize(attributes:, sessions:)
      @attributes = attributes
      @sessions = sessions
    end
  end

  def collect_stats_from_users(report, users_objects)
    users_objects.each do |user|
      user_key = "#{user.attributes['first_name']} #{user.attributes['last_name']}"
      report['usersStats'][user_key] ||= {}
      report['usersStats'][user_key] = report['usersStats'][user_key].merge(yield(user))
    end
  end

  def self.report(users, sessions, sessions_hash)
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
    uniqueBrowsers = []
    sessions.each do |session|
      browser = session['browser']
      uniqueBrowsers += [browser] if uniqueBrowsers.all? { |b| b != browser }
    end

    report['uniqueBrowsersCount'] = uniqueBrowsers.count

    report['totalSessions'] = sessions.count

    report['allBrowsers'] =
      sessions
      .map { |s| s['browser'] }
      .map(&:upcase)
      .sort
      .uniq
      .join(',')

    # Статистика по пользователям
    users_objects = []

    users.each do |user|
      attributes = user
      # user_sessions = sessions.select { |session| session['user_id'] == user['id'] }
      user_sessions = sessions_hash[user['id']]
      user_object = User.new(attributes:, sessions: user_sessions)
      users_objects.concat([user_object])
    end

    report['usersStats'] = {}

    # Собираем количество сессий по пользователям
    collect_stats_from_users(report, users_objects) do |user|
      { 'sessionsCount' => user.sessions.count }
    end

    # Собираем количество времени по пользователям
    collect_stats_from_users(report, users_objects) do |user|
      { 'totalTime' => user.sessions.map { |s| s['time'] }.map(&:to_i).sum.to_s + ' min.' }
    end

    # Выбираем самую длинную сессию пользователя
    collect_stats_from_users(report, users_objects) do |user|
      { 'longestSession' => user.sessions.map { |s| s['time'] }.map(&:to_i).max.to_s + ' min.' }
    end

    # Браузеры пользователя через запятую
    collect_stats_from_users(report, users_objects) do |user|
      { 'browsers' => user.sessions.map { |s| s['browser'] }.map(&:upcase).sort.join(', ') }
    end

    # Хоть раз использовал IE?
    collect_stats_from_users(report, users_objects) do |user|
      { 'usedIE' => user.sessions.map { |s| s['browser'] }.any? { |b| b.upcase =~ /INTERNET EXPLORER/ } }
    end

    # Всегда использовал только Chrome?
    collect_stats_from_users(report, users_objects) do |user|
      { 'alwaysUsedChrome' => user.sessions.map { |s| s['browser'] }.all? { |b| b.upcase =~ /CHROME/ } }
    end

    # Даты сессий через запятую в обратном порядке в формате iso8601
    collect_stats_from_users(report, users_objects) do |user|
      { 'dates' => user.sessions.map { |s| s['date'] }.sort.reverse }
    end

    report
  end
end
