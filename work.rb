require 'oj'

class ReportBuilder
  def initialize(file)
    @file = file
    @sessions = 0
    @all_browsers = []
    @user_sessions = {}
  end

  def work
    parse_data
    build_report
  end

  private

  def parse_data
    file = File.new(@file)
    file.each do |line|
      cols = line.chomp!.split(',')
      cols[0] == 'user' ? parse_user(cols) : parse_session(cols)
    end
    file.close
  end

  def parse_user(cols)
    @user_sessions[cols[1]] ||= {}
    @user_sessions[cols[1]]['name'] = "#{cols[2]} #{cols[3]}"
  end

  def parse_session(cols)
    @sessions += 1
    current_user = @user_sessions[cols[1]]

    browser = cols[3].upcase

    current_user['browsers'] = (current_user['browsers'] || []) << browser
    current_user['used_ie'] ||= true if browser.start_with?('INTERNET EXPLORER')
    current_user['used_chrome'] = false unless browser.start_with?('CHROME')
    @all_browsers << browser

    current_user['time'] = (current_user['time'] || []) << cols[4].to_i
    current_user['dates'] = (current_user['dates'] || []) + [cols[5]]
  end

  def build_report
    report = {}
    report[:totalUsers] = @user_sessions.count
    report[:uniqueBrowsersCount] = @all_browsers.uniq!.count
    report[:totalSessions] = @sessions
    report[:allBrowsers] = @all_browsers.sort!.join(',')

    report[:usersStats] = {}
    @user_sessions.each_value do |val|
      report[:usersStats][val['name']] = {
        'sessionsCount': val['sessions_count'],
        'totalTime': val['browsers'].count,
        'longestSession': val['time'].max.to_s + ' min.',
        'browsers': val['browsers'].sort!.join(', '),
        'usedIE': val['used_ie'] || false,
        'alwaysUsedChrome': val['used_chrome'].nil? ? true : false,
        'dates': val['dates'].sort!.reverse!
      }
    end

    File.write('result.json', Oj.dump(report, mode: :compat))
    File.write('result.json', "\n", mode: 'a')
  end
end

def work(file)
  ReportBuilder.new(file).work
end
