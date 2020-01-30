# Deoptimized version of homework task

require 'oj'

require './user'
require './session'
require './sessions_list'
require './report_builder'

Oj.mimic_JSON

def work(file_path, disable_gc: false)
  GC.disable if disable_gc

  cur_user = nil
  users = []
  sessions_list = SessionsList.new

  IO.foreach(file_path) do |line|
    cols = line.split(',')
    if cols[0] == 'user'
      cur_user = User.new(cols)
      users << cur_user
    else
      session = Session.new(cols)
      cur_user.sessions_list << session
      sessions_list << session
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

  report = ReportBuilder.call(users, sessions_list)

  File.write('result.json', "#{report.to_json}\n")
end

