# frozen_string_literal: true

module V3
  extend self

  def parse_user(user)
    fields = /(\w+),(\w+),(\w+),(\w+),(\w+)/.match(user)
    {
      'id' => fields[2],
      'first_name' => fields[3],
      'last_name' => fields[4],
      'age' => fields[5]
    }
  end

  def parse_session(session)
    fields = /(\w+),(\w+),(\w+),([a-zA-Z0-9_ ]+),(\w+),([0-9-]+)/.match(session)

    {
      'user_id' => fields[2],
      'session_id' => fields[3],
      'browser' => fields[4],
      'time' => fields[5],
      'date' => fields[6]
    }
  end

  def parse(file_lines)
    users = []
    sessions = []
    sessions_hash = {}

    file_lines.each do |line|
      is_user = line.start_with? ('user')
      is_session = line.start_with? ('session')
    
      users.concat([parse_user(line)]) if is_user
      
      session = parse_session(line) if is_session
      sessions.concat([session]) if is_session
      next unless is_session
      
      if sessions_hash[session['user_id']].nil?
        sessions_hash[session['user_id']] = [session]
      else
        sessions_hash[session['user_id']].concat([session])
      end
    end

    [users, sessions, sessions_hash]
  end
end
