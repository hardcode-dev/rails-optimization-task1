class ReportBuilder
  attr_reader :users, :sessions_list, :report

  def self.call(users, sessions_list)
    new(users, sessions_list).call
  end

  def initialize(users, sessions_list)
    @report = {}
    @users = users
    @sessions_list = sessions_list
  end

  def call
    {
      totalUsers: users.count,
      uniqueBrowsersCount: unique_browsers.count,
      totalSessions: sessions_list.count,
      allBrowsers: all_browsers,
      usersStats: users_stats
    }
  end

  private

  def unique_browsers
    @unique_browsers ||= sessions_list.unique_browsers.sort
  end

  def all_browsers
    unique_browsers.join(',')
  end

  def users_stats
    users.reduce({}) do |acc, user|
      acc[user.name] = user.stats
      acc
    end
  end
end