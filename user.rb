class User
  attr_reader :attributes, :sessions, :key

  def initialize(attributes:, sessions:)
    @attributes = attributes
    @sessions = sessions
    @key = set_key
  end

  private

  def set_key
    "#{self.attributes['first_name']} #{self.attributes['last_name']}"
  end
end
