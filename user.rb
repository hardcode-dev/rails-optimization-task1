class User
  attr_reader :attributes, :sessions

  def initialize(attributes:, sessions: [])
    @attributes = attributes
    @sessions = sessions
  end

  def push_session(session)
    @sessions << session
  end

  def full_name
    "#{attributes['first_name']} #{attributes['last_name']}"
  end

  def stats
    {
      'sessionsCount' => sessions.count,
      'totalTime' => "#{total_time} min.",
      'longestSession' => "#{longest_session['time']} min.",
      'browsers' => browsers_list,
      'usedIE' => used_ie?,
      'alwaysUsedChrome' => always_used_chrome?,
      'dates' => dates
    }
  end

  def total_time
    sessions.reduce(0) do |acc, session|
      acc += session['time'].to_i
      acc
    end
  end

  def longest_session
    sessions.max { |s1, s2| s1['time'].to_i <=> s2['time'].to_i }
  end

  def browsers_list
    browsers.sort.join(', ')
  end

  def used_ie?
    browsers.any? { |b| b.match? /INTERNET EXPLORER/ }
  end

  def always_used_chrome?
    browsers.all? { |b| b.match? /CHROME/ }
  end

  def dates
    dates_list.sort {|d1, d2| d2 <=> d1 }
  end

  private

  def browsers
    @browsers ||= sessions.map {|s| s['browser'].upcase }
  end

  def dates_list
    sessions.map { |ses| ses['date'].strip }
  end
end