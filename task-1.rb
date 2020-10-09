# frozen_string_literal: true

require 'json'
require 'byebug'
require 'ruby-progressbar'
require_relative 'models/user'

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
    'user_id' => fields[1],
    'session_id' => fields[2],
    'browser' => fields[3].upcase,
    'time' => fields[4].to_i,
    'date' => fields[5]
  }
end


def work(file_path = 'data_large.txt')
  file_lines = File.read(file_path).split("\n")
  users = []
  sessions = {}
  parsing_progressbar = ProgressBar.create(:format => "%a %e %b\u{15E7}%i %p%% %t",
                                           :progress_mark => ' ',
                                           :remainder_mark => "\u{FF65}",
                                           :title => "Reading file",
                                           :total => file_lines.length)
  file_lines.each do |line|
    fields = line.split(',')
    users << parse_user(fields) if fields[0] == 'user'
    (sessions[fields[1]] ||= []) << parse_session(fields) if fields[0] == 'session'
    parsing_progressbar.increment
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

  report[:totalUsers] = users.length
  # Подсчёт количества уникальных браузеров
  unique_browsers = sessions.values.flatten.map { |session| session['browser'] }.uniq

  report['uniqueBrowsersCount'] = unique_browsers.length
  report['totalSessions'] = sessions.values.flatten.length
  report['allBrowsers'] = unique_browsers.sort.join(',')

  # Статистика по пользователям
  users_objects = []
  report['usersStats'] = {}
  report_progress_bar = ProgressBar.create(:format => "%a %e %b\u{15E7}%i %p%% %t",
                                           :progress_mark => ' ',
                                           :remainder_mark => "\u{FF65}",
                                           :title => "making report...",
                                           :total => users.length)

  users.each do |user|
    report_progress_bar.increment

    attributes = user
    user_sessions = sessions[user['id']]
    user_object = User.new(attributes: attributes, sessions: user_sessions)
    users_objects += [user_object]
    report['usersStats'][user_object.key] ||= {}
    report['usersStats'][user_object.key] = report['usersStats'][user_object.key].merge(user_object.user_stats)
  end

  File.write('result.json', "#{report.to_json}\n")
end

work
