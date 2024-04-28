def parse_user(user)
    fields = user.split(',')
    parsed_result = {
      'id' => fields[1],
      'first_name' => fields[2],
      'last_name' => fields[3],
      'age' => fields[4],
    }
  end
  
  def parse_session(session)
    fields = session.split(',')
    parsed_result = {
      'user_id' => fields[1],
      'session_id' => fields[2],
      'browser' => fields[3],
      'time' => fields[4],
      'date' => fields[5],
    }
  end


  def parse(file_lines)
    users = []
    sessions = []
    
    file_lines.each do |line|
        cols = line.split(',')
        users = users + [parse_user(line)] if cols[0] == 'user'
        sessions = sessions + [parse_session(line)] if cols[0] == 'session'
      end

    [users, sessions]
  end
