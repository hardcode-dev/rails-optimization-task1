class User
  attr_reader :attributes, :sessions

  def initialize(attributes:)
    @attributes = attributes
    @sessions   = attributes.delete(:sessions)
  end

  def id
    attributes[:id]
  end
end
