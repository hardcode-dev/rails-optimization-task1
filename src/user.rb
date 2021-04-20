# frozen_string_literal: true

class User
  attr_reader :attributes, :sessions, :key, :total_session_time, :max_session_time

  def initialize(attributes)
    @attributes = attributes
    @sessions = []

    @total_session_time = 0
    @max_session_time = 0

    @key = "#{attributes['first_name']} #{attributes['last_name']}".freeze
  end

  def add_session(session)
    session_time = session.delete('time').to_i
    @total_session_time += session_time
    @max_session_time = session_time if @max_session_time < session_time

    @sessions.push session
  end
end