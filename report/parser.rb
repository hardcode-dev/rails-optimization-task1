# frozen_string_literal: true

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

  file_lines.each do |line|
    cols = line.split(',')
    users += [parse_user(line)] if cols[0] == 'user'
    sessions += [parse_session(line)] if cols[0] == 'session'
  end

  [users, sessions]
end
