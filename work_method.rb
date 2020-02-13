# Deoptimized version of homework task

require 'json'
require 'pry'
require 'date'
require 'oj'

def work(filename = '', disable_gc: true)
  puts 'Start work'
  GC.disable if disable_gc
  file_lines = File.read(ENV['DATA_FILE'] || filename).split("\n")

  users = []
  sessions = {}
  report = {
    totalUsers: 0,
    uniqueBrowsersCount: 0,
    totalSessions: 0,
    allBrowsers: nil,
  }
  report[:usersStats] = {}

  user_key = nil
  file_lines.each do |line|
    cols = line.split(',')
    if cols[0] == 'user'

      user_key = "#{cols[2]}" + ' ' + "#{cols[3]}"
      report[:usersStats][user_key] = {
        sessionsCount: 0,
        totalTime: 0,
        longestSession: 0,
        browsers: [],
        usedIE: false,
        alwaysUsedChrome: true,
        dates: [],
      }
      report[:totalUsers] += 1
    else
      cols[3].upcase!
      cols[4] = cols[4].to_i
      user = report[:usersStats][user_key]
      user[:sessionsCount] += 1
      user[:totalTime] += cols[4]
      user[:longestSession] = cols[4] if user[:longestSession] < cols[4]
      user[:browsers].push(cols[3])
      user[:usedIE] = true if !user[:usedIE] && cols[3].start_with?('INTERNET')
      user[:usedIE] = true if user[:alwaysUsedChrome] && !cols[3].start_with?('CHROME')
      user[:dates].push(cols[5])
      report[:totalSessions] += 1
      sessions[cols[3]] = nil
    end
  end

  report[:uniqueBrowsersCount] = sessions.keys.count
  report[:allBrowsers] = sessions.keys.sort!.join(',')

  report[:usersStats].each do |_, user|
    user[:totalTime] = "#{user[:totalTime]} min."
    user[:longestSession] = "#{user[:longestSession]} min."
    user[:dates] = user[:dates].sort!.reverse!
    user[:browsers] = user[:browsers].sort!.join(', ')
  end

  File.open('result.json', 'w') do |f|
    f.write Oj.dump(report, mode: :compat)
    f.write "\n"
  end
end
