# frozen_string_literal: true

module V1
  module_function

  def parse_user(user)
    fields = user.split(',')
    {
      'id' => fields[1],
      'first_name' => fields[2],
      'last_name' => fields[3],
      'age' => fields[4]
    }
  end

  def parse_session(session)
    fields = session.split(',')
    {
      'user_id' => fields[1],
      'session_id' => fields[2],
      'browser' => fields[3],
      'time' => fields[4],
      'date' => fields[5]
    }
  end

  def parse(file_lines)
    users = []
    sessions = []
    sessions_hash = {}

    file_lines.each do |line|
      cols = line.split(',')
      users += [parse_user(line)] if cols[0] == 'user'
      sessions += [parse_session(line)] if cols[0] == 'session'
      next unless cols[0] == 'session'

      session = parse_session(line)
      if sessions_hash[session['user_id']].nil?
        sessions_hash[session['user_id']] = [session]
      else
        sessions_hash[session['user_id']] << session
      end
    end

    [users, sessions, sessions_hash]
  end
end
