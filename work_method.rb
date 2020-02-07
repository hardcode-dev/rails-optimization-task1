# Deoptimized version of homework task

require 'json'
require 'pry'
require 'date'

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
        usedIE: 0,
        alwaysUsedChrome: 0,
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
      user[:dates].push(cols[5])
      report[:totalSessions] += 1
      sessions[cols[3]] = nil
    end
  end

  report[:uniqueBrowsersCount] = sessions.keys.count
  report[:allBrowsers] = sessions.keys.sort!.join(',')

  report[:usersStats].each do |_, user|
    browsers = user[:browsers].sort.join(', ')
    user[:totalTime] = "#{user[:totalTime]} min."
    user[:longestSession] = "#{user[:longestSession]} min."
    user[:dates] = user[:dates].sort!.reverse!
    user[:usedIE] = browsers.include?('INTERNET')
    user[:alwaysUsedChrome] = user[:browsers].all? { |b| b =~ /CHROME/ }
    user[:browsers] = browsers
  end

  File.write('result.json', "#{report.to_json}\n")
end
