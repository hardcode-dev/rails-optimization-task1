# frozen_string_literal: true

class User
  attr_reader :attributes, :sessions, :session_durations, :session_dates, :sessions_count

  def initialize(attributes:, sessions:)
    @attributes = attributes
    @sessions = sessions
    @sessions_count = 0
    @sessions_total_time = 0
    @session_durations = []
    @session_dates = []
    @longest_session = 0
    @used_ie = false
    @chrome_fan = true
    @browsers = []
    init_session_stats
  end

  def key
    @key ||= attributes['first_name'].to_s + ' ' + attributes['last_name'].to_s
  end

  def browsers
    @browsers.sort.join(', ')
  end

  def sessions_total_time
    @sessions_total_time.to_s + ' min.'
  end

  def longest_session
    @longest_session.to_s + ' min.'
  end

  def used_ie?
    @used_ie
  end

  def chrome_fan?
    @chrome_fan && sessions_count > 0
  end

  def user_stats
    { 'sessionsCount' => sessions_count,
      'totalTime' => sessions_total_time,
      'longestSession' => longest_session,
      'browsers' => browsers,
      'usedIE' => used_ie?,
      'alwaysUsedChrome' => chrome_fan?,
      'dates' => session_dates.sort.reverse
    }
  end

  private

  def init_session_stats
    sessions.each do |s|
      @browsers << s['browser']
      @used_ie = true if s['browser'] =~ /INTERNET EXPLORER/
      @chrome_fan = false if s['browser'] !~ /CHROME/
      @session_durations << s['time']
      @sessions_total_time += s['time']
      @session_dates << s['date']
      @longest_session = s['time'] if s['time'] > @longest_session
      @sessions_count += 1
    end
  end
end
