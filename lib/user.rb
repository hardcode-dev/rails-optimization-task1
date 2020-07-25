class User
  attr_reader :attributes, :sessions_count, :browsers

  def initialize(id)
    @id = id
    @info = {}

    @sessions_count = 0
    @times = []
    @browsers = []
    @dates = []
  end

  def set_info(info)
    @info = info
  end

  def add_session(session)
    # Собираем количество сессий по пользователям
    @sessions_count += 1

    @times << session['time'].to_i
    @browsers << session['browser']
    @dates << session['date']
  end

  # Собираем количество времени по пользователям
  def total_time
    @times.sum
  end

  # Выбираем самую длинную сессию пользователя
  def longest_session
    @times.max
  end

  # Хоть раз использовал IE?
  def used_ie?
    @browsers.any? { |b| b.upcase =~ /INTERNET EXPLORER/ }
  end

  # Всегда использовал только Chrome?
  def used_only_chrome?
    @browsers.all? { |b| b.upcase =~ /CHROME/ }
  end

  # Даты сессий через запятую в обратном порядке в формате iso8601
  def last_session_dates
    @dates.sort.reverse
  end

  def key
    "#{@info['first_name']} #{@info['last_name']}"
  end
end

