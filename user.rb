require './sessions_list'

class User
  attr_reader :name, :sessions_list

  def initialize(attributes)
    @name = "#{attributes[2]} #{attributes[3]}"
    @sessions_list = SessionsList.new
  end

  def stats_object
    { "#{name}": stats }
  end

  def stats
    {
      sessionsCount: sessions_list.count,
      totalTime: "#{sessions_list.total_time} min.",
      longestSession:  "#{sessions_list.longest_session.time} min.",
      browsers: browsers_list,
      usedIE: used_ie?,
      alwaysUsedChrome: always_used_chrome?,
      dates: sessions_list.sorted_dates
    }
  end

  def browsers_list
    sessions_list.browsers.sort.join(', ')
  end

  def used_ie?
    sessions_list.browsers.any? { |b| b.match? /INTERNET EXPLORER/ }
  end

  def always_used_chrome?
    sessions_list.browsers.all? { |b| b.match? /CHROME/ }
  end
end