# Deoptimized version of homework task

require 'json'

# Создание Юзера запускать тредами
class User
  attr_accessor :sessions, :name

  def update
    yield self
  end

  def self.instance
    @@user ||= nil
  end

  def initialize(name, sessions: { sessionsCount: 0,
                                          totalTime: 0,
                                          longestSession: 0,
                                          browsers: [],
                                          dates: [] } )
    @name = name
    @sessions = sessions
    @@user = self
  end

  def used_ie?
    sessions[:browsers].any? { |browser| browser =~ /Internet Explorer/ }
  end

  def always_used_chrome?
    sessions[:browsers].all? { |browser| browser =~ /Chrome/ }
  end
end

# запуск синхроно либо Mutex
def make_report(report)
  report[:usersStats].merge!({ User.instance.name => {
                                  sessionsCount:    User.instance.sessions[:sessionsCount],
                                  totalTime:        "#{User.instance.sessions[:totalTime]} min.",
                                  longestSession:   "#{User.instance.sessions[:longestSession]} min.",
                                  browsers:         User.instance.sessions[:browsers],
                                  usedIE:           User.instance.used_ie?,
                                  alwaysUsedChrome: User.instance.always_used_chrome?,
                                  dates:            User.instance.sessions[:dates]
                              }})

  report[:totalUsers] += 1
  # report[:uniqueBrowsersCount] = browser.count
  report[:totalSessions] += User.instance.sessions[:sessionsCount]
  # report[:allBrowsers] = browser.join(' ')
end

def work(file = 'data.txt', disable_gc: false)
  GC.disable if disable_gc

  @file_result = File.new('result.json', 'w')
  @report = { totalUsers: 0, uniqueBrowsersCount: 0, totalSessions: 0, allBrowsers: 0, usersStats: {} }

  File.foreach(file) do |line|
    cols = line.split(',')

    if cols.first.eql? 'user'
      make_report(@report) if User.instance

      User.new("#{cols[2]} #{cols[3]}")
    elsif cols.first.eql? 'session'
      User.instance.update do |user|
        user.sessions[:sessionsCount] += 1
        user.sessions[:browsers] << cols[3]
        user.sessions[:dates] << cols[5].chomp
        user.sessions[:totalTime] += cols[4].to_i
        user.sessions[:longestSession] = cols[4].to_i if user.sessions[:longestSession] < cols[4].to_i
      end
    end
  end

  make_report(@report)
  @file_result.write("#{@report.to_json}\n")
  @file_result.close
end
