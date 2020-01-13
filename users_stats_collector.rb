class UsersStatsCollector
  attr_reader :users

  def self.call(users)
    new(users).call
  end

  def initialize(users)
    @users = users
  end

  def call
    users.reduce({}) do |acc, user|
      user_key = user.full_name
      acc[user_key] = user.stats
      acc
    end
  end
end
