require "set"
require "oj"

class Report
  attr_reader :file_path

  attr_accessor :report, :user_keys

  def initialize(file_path)
    @file_path = file_path
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
    @report = {}
    # Ключи пользователей по ID.
    # {
    #   "1" => "Ivan Petrov",
    #   "2" => "Igor Morozov",
    # }
    @user_keys = {}
  end

  def work
    file_data = File.open(file_path).read

    setup_defaults

    file_data.each_line do |line|
      cols = line.split(",")

      if cols[0] == "user"
        process_user(cols)
      elsif cols[0] == "session"
        process_session(cols)
      end
    end

    prepare_browsers_information
    prepare_users_information

    File.write("result.json", Oj.dump(report) + "\n")
  end

  # Стандартные значения для финального отчета.
  def setup_defaults
    report["totalUsers"] = 0
    report["uniqueBrowsersCount"] = 0
    report["totalSessions"] = 0
    report["allBrowsers"] = SortedSet[]
  end

  # Обработка строки пользователя.
  def process_user(cols)
    # 0 - row type
    # 1 - user id
    # 2 - first name
    # 3 - last name
    # 4 - age
    user_key = "#{cols[2]} #{cols[3]}"

    # Сохраним, чтобы сразу мэтчить сессии к пользователю в финальном отчете.
    user_keys[cols[1]] = user_key
    report["usersStats"] ||= {}
    report["usersStats"][user_key] ||= {}

    user_hash = report["usersStats"][user_key]

    # Setup defaults.
    user_hash["sessionsCount"] ||= 0
    user_hash["totalTime"] ||= 0
    user_hash["longestSession"] ||= 0
    user_hash["browsers"] ||= []
    user_hash["usedIE"] ||= false
    user_hash["alwaysUsedChrome"] ||= false
    user_hash["dates"] ||= SortedSet[]
    # Данные для общего отчета.
    # Общее кол-во пользователей.
    report["totalUsers"] += 1
  end

  # Обрабокта строки сессии.
  def process_session(cols)
    # 0 - row type
    # 1 - user id
    # 2 - session id
    # 3 - browser
    # 4 - session time
    # 5 - date
    user_key = user_keys[cols[1]]

    user_hash = report["usersStats"][user_key]

    session_time = cols[4].to_i

    # Сессии пользователя.
    user_hash["sessionsCount"] += 1
    # Общее время сессий.
    user_hash["totalTime"] += session_time
    # Самая долгая сессия.
    user_hash["longestSession"] = session_time if session_time > user_hash["longestSession"]
    # Браузеры.
    user_hash["browsers"] << cols[3].upcase
    # Использовал IE.
    user_hash["usedIE"] = true if cols[3].match?(/INTERNET EXPLORER/i)
    # Использовал только chrome.
    user_hash["alwaysUsedChrome"] = false unless cols[3].match?(/CHROME/)
    # Даты сессий.
    user_hash["dates"] << cols[5].delete!("\n")

    # Данные для общего отчета.
    # Общее кол-во сессий.
    report["totalSessions"] += 1
    # Все браузеры.
    report["allBrowsers"].add(cols[3].upcase)
  end

  # Информация о браузерах.
  def prepare_browsers_information
    report["uniqueBrowsersCount"] = report["allBrowsers"].count
    report["allBrowsers"] = report["allBrowsers"].to_a.join(",")
  end

  # Преобразование данных о пользователях к нужному формату.
  def prepare_users_information
    report["usersStats"].each do |k, v|
      report["usersStats"][k]["browsers"] = report["usersStats"][k]["browsers"].sort.join(", ")
      report["usersStats"][k]["totalTime"] = report["usersStats"][k]["totalTime"].to_s + " min."
      report["usersStats"][k]["longestSession"] = report["usersStats"][k]["longestSession"].to_s + " min."
      report["usersStats"][k]["dates"] = report["usersStats"][k]["dates"].to_a.reverse
    end
  end
end
