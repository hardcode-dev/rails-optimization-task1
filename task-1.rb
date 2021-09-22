# Deoptimized version of homework task

require 'json'
require 'pry'
require 'date'
require 'minitest/autorun'


def work(filename = 'data.txt')

  file_lines = File.read(filename).split("\n")

  users = {}
  total_users = 0
  total_sessions = 0

  file_lines.each do |line|
    cols = line.split(',')
    if cols[0] == 'user'
      total_users += 1
      users[cols[1]] = {name: "#{cols[2]} #{cols[3]}", sessions_count: 0, total_time: 0, longest_session: 0, browsers: [], dates: [], always_chrome: true}
    elsif cols[0] == 'session'
      total_sessions += 1
      users[cols[1]][:sessions_count] += 1
      time = cols[4].to_i
      users[cols[1]][:total_time] += time
      current_longest_session = users[cols[1]][:longest_session] 
      users[cols[1]][:longest_session] = current_longest_session > time ? current_longest_session : time
      browser = cols[3]
      users[cols[1]][:browsers] << browser
      if !browser.include?('Chrome')
        users[cols[1]][:always_chrome] = false
      end
      users[cols[1]][:dates] << cols[5]
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

  report = {}

  report[:totalUsers] = total_users

  # Подсчёт количества уникальных браузеров
  uniqueBrowsers = users.values.map{ |user| user[:browsers].uniq}.flatten.uniq.sort

  report['uniqueBrowsersCount'] = uniqueBrowsers.count

  report['totalSessions'] = total_sessions

  report['allBrowsers'] = uniqueBrowsers.map{|browser| browser.upcase}.join(',')

  # Статистика по пользователям
  user_stats = {}

  

  users.each do |id, user|

    user_browsers = user[:browsers].map{|user_browser| user_browser.upcase}.sort.join(', ')

    user_stats[user[:name]] = {
      "sessionsCount": user[:sessions_count],
      "totalTime": "#{user[:total_time]} min.",
      "longestSession": "#{user[:longest_session]} min.",
      "browsers": user_browsers,
      "usedIE": user_browsers.include?('INTERNET EXPLORER'),
      "alwaysUsedChrome": user[:always_chrome],
      "dates": user[:dates].uniq.sort{|a,b| b <=> a }
    }
  end

  report['usersStats'] = user_stats

  File.write('result.json', "#{report.to_json}\n")
end

