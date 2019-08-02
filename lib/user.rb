class User
  attr_reader :attributes
  attr_accessor :sessions

  def initialize(attributes:, sessions: [])
    @attributes = attributes
    @sessions = sessions
  end
end
