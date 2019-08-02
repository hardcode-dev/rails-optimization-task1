class Task
  def initialize(result_file_path: nil, data_file_path: nil, dasable_gc: true)
    GC.disable if dasable_gc
    @result_file_path = result_file_path || 'data/result.json'
    @data_file_path = data_file_path || 'data/data_large.txt'
  end

  def parse_user(fields)
    {
      id: fields[1],
      full_name: "#{fields[2]} #{fields[3]}"
    }
  end

  def parse_session(fields)
    {
      user_id: fields[1],
      session_id: fields[2],
      browser: fields[3].upcase,
      time: fields[4].to_i,
      date: fields[5].chomp,
    }
  end

  def collect_stats_from_user(report, user)
    user_key =user.attributes[:full_name]
    report[:usersStats][user_key] ||= {}
    report[:usersStats][user_key] = report[:usersStats][user_key].merge(yield(user))
  end

  def work
    user_objects = []
    sessions = []
    uniqueBrowsers = Set.new

    File.foreach(data_file_path) do |line|
      cols = line.split(',')
      if cols[0] == 'user'
        @user = User.new(attributes: parse_user(cols), sessions: [])
        user_objects << @user
      end

      if cols[0] == 'session'
        session = parse_session(cols)
        uniqueBrowsers << session[:browser]
        sessions << session
        @user.sessions << session
      end
    end

    report = {}

    report[:totalUsers] = user_objects.count
    progress_bar = ProgressBar.create(total: user_objects.count, format: '%a, %J, %E %B')

    report[:uniqueBrowsersCount] = uniqueBrowsers.count
    report[:totalSessions] = sessions.count
    report[:allBrowsers] = uniqueBrowsers.sort.join(',')
    report[:usersStats] = {}

    user_objects.each do |user_object|
      prepare_stats(report, user_object)
      progress_bar.increment
    end

    File.write(result_file_path, "#{Oj.dump(report, mode: :compat)}\n")
  end

  private

  attr_reader :result_file_path, :data_file_path

  def prepare_stats(report, user_object)
    collect_stats_from_user(report, user_object) do |user|
      user_times = user.sessions.map { |session| session[:time] }
      user_browsers = user.sessions.map { |session| session[:browser] }
      user_dates = user.sessions.map { |session| session[:date] }

      {
        sessionsCount: user.sessions.count,
        totalTime:  "#{user_times.sum} min.",
        longestSession:  "#{user_times.max} min.",
        browsers: user_browsers.sort.join(', '),
        usedIE: user_browsers.any? { |b| b.match? /INTERNET EXPLORER/ },
        alwaysUsedChrome: user_browsers.all? { |b| b.match? /CHROME/ },
        dates: user_dates.sort { |a, b| b <=> a }
      }
    end
  end
end
