class User
  attr_reader :attributes, :sessions
  attr_accessor :ie_user

  def initialize(attributes:, sessions:)
    @attributes = attributes
    @sessions = sessions
    @ie_user = false
  end
end