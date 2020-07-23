class User
  attr_reader :attributes, :sessions

  def initialize(attributes:, sessions: [])
    @attributes = attributes
    @sessions = sessions
  end

  def add_sessions(sessions)
    @sessions = sessions
  end

  def fullname
    @fullname ||= "#{attributes['first_name']} #{attributes['last_name']}"
  end
end
