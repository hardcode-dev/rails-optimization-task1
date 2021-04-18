# frozen_string_literal: true

class User
  attr_reader :attributes, :sessions

  def initialize(attributes:, sessions: [])
    @attributes = attributes
    @sessions = sessions
  end

  def add_session(session)
    @sessions.push session
  end
end