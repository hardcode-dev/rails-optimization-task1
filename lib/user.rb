class User
  attr_accessor :id, :first_name, :last_name, 
                :full_name, :age, :sessions, 
                :sessions_count, :total_time, :use_ie, :longest_session, :dates

  def initialize(id:, first_name:, last_name:, full_name:, age:, sessions:[])
    @id = id
    @first_name = first_name
    @last_name = last_name
    @full_name = full_name
    @age = age
    @sessions = sessions
    @sessions_count = 0
    @total_time = 0
    @use_ie = false
    @longest_session = 0
    @dates = []
  end

  def add_sessions(session)
    self.sessions << session
  end

  def inc
    self.sessions_count += 1
  end

  def update_total_time(time)
    self.total_time += time
  end

  def update_longest_session(time)
    self.longest_session = self.longest_session > time ? self.longest_session : time
  end

  def add_dates(date)
    self.dates << date
  end
end