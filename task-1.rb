require 'set'
require 'oj'
require 'ruby-progressbar'

def parse_session(session)
  fields = session.split(',')
  {
    user_id: fields[1].to_i,
    # fields[2] session_id is not using
    browser: fields[3].upcase,
    time: fields[4].to_i,
    date: fields[5],
  }
end

def work(path = nil)
  path = path.nil? ? 'data_large.txt' : path
  file_lines = File.read(path).split("\n")

  users = {}
  sessions = {}
  browsers = Set[]
  total_sessions_counts = 0

  file_lines.each do |line|
    cols = line.split(',')

    if cols[0] == 'user'
      users[cols[1].to_i] = "#{cols[2]} #{cols[3]}"
    else
      session = parse_session(line)
      sessions[session[:user_id]] ||= []
      sessions[session[:user_id]] << session
      browsers << session[:browser].upcase
      total_sessions_counts += 1
    end
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

  report = {
    totalUsers: users.size,
    uniqueBrowsersCount: browsers.size,
    totalSessions: total_sessions_counts,
    allBrowsers: browsers.sort.join(','),
    usersStats: {}
  }

  progressbar = create_progressbar(users.size)

  users.each do |user_id, user_name|
    sessions_times_by_user = sessions[user_id].map { |s| s[:time] }
    sessions_browsers_by_user = sessions[user_id].map { |s| s[:browser] }

    report[:usersStats][user_name] = {}

    report[:usersStats][user_name][:sessionsCount] = sessions[user_id].size

    report[:usersStats][user_name][:totalTime] = "#{sessions_times_by_user.sum} min."

    report[:usersStats][user_name][:longestSession] = "#{sessions_times_by_user.max} min."

    report[:usersStats][user_name][:browsers] = sessions_browsers_by_user.sort.join(', ')

    report[:usersStats][user_name][:usedIE] = sessions_browsers_by_user.any? { |b| b.start_with?('INTERNET EXPLORER') }

    report[:usersStats][user_name][:alwaysUsedChrome] = sessions_browsers_by_user.all? { |b| b.start_with?('CHROME') }

    report[:usersStats][user_name][:dates] = sessions[user_id].map { |s| s[:date] }.sort.reverse!

    progressbar.increment
  end

  File.write('result.json', "#{Oj.to_json(report, mode: :compat)}\n")
end

def create_progressbar(countable_var)
  ProgressBar.create(
    total: countable_var,
    format: '%a, %J, %E %B'
  )
end
