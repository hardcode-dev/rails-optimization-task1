class User
  attr_reader :attributes, :sessions, :full_name, :id

  def initialize(attributes:)
    @attributes = attributes
    @sessions   = attributes.delete(:sessions)
    @full_name  = "#{attributes[:first_name]} #{attributes[:last_name]}"
    @id         = attributes[:id]
  end
end
