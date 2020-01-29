class SessionsList
  attr_reader :sessions

  def initialize
    @sessions = []
  end

  def <<(session)
    sessions << session
  end

  def unique_browsers
    sessions.reduce([]) do |browsers, session|
      browser = session.browser
      browsers << browser unless browsers.include? browser
      browsers
    end
  end

  def count
    sessions.count
  end

  def total_time
    sessions.inject(0) { |sum, session| sum + session.time }
  end

  def longest_session
    sessions.max { |s1, s2| s1.time <=> s2.time }
  end

  def sorted_dates
    sessions.map(&:date).sort {|d1, d2| d2 <=> d1 }
  end

  def browsers
    @browsers ||= sessions.map(&:browser)
  end
end