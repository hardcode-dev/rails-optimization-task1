class Session
  attr_reader :browser, :time, :date

  def initialize(attributes)
    @browser = attributes[3].upcase
    @time = attributes[4].to_i
    @date = attributes[5].strip
  end
end