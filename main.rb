# Deoptimized version of homework task

require 'json'
require 'pry'
require 'date'
require 'ruby-prof'
require 'stackprof'

require 'ruby-progressbar'
Dir[File.join(__dir__, 'class', '*.rb')].each { |file| require file }

def parse_user(user)
  fields = user.split(',')

  User.new(
    fields[1],
    fields[2] + ' ' + fields[3],
    fields[4]
  )
end

def parse_session(session, users)
  fields = session.split(',')

  session = Session.new(
    fields[3].upcase!,
    fields[4].to_i,
    fields[5],
  )

  user_id = fields[1]
  user = users[user_id]
  user.sessions << session
  user.report.process(session)
  session
end

def collect_stats_from_users(report, users)
  users.each do |_id, user|
    user_key = user.name
    report['usersStats'][user_key] ||= {}
    hash_report = report['usersStats'][user_key]
    hash_report['sessionsCount'] = user.sessions.count
    hash_report['totalTime'] = user.report.total_time.to_s + ' min.'
    hash_report['longestSession'] = user.report.longest_session.to_s + ' min.'
    hash_report['browsers'] = user.report.browsers.sort.join(', ')
    hash_report['usedIE'] =  user.report.usedIE
    hash_report['alwaysUsedChrome'] =  user.report.always_used_chrome
    hash_report['dates'] = user.report.dates.sort.reverse
  end
end

def work(file)
  start = Time.now

  file_lines = File.read(file).split("\n")

  users = {}
  global_report = GlobalReport.new

  # progressbar = ProgressBar.create(
  #   total: 3250940,
  #   format: '%a %J, %E %B'
  # )
  File.readlines(file).each do |line|
    cols = line.split(',')

    if cols[0] == 'user'
      user = parse_user(line)
      users[user.id] = user
    else
      session = parse_session(line, users)
      global_report.process(session)
    end

    # progressbar.increment
  end

  report = {}

  report['totalUsers'] = users.count

  report['uniqueBrowsersCount'] = global_report.unique_browsers.count

  report['totalSessions'] = global_report.total_sessions

  report['allBrowsers'] = global_report.unique_browsers.sort.join(',')

  report['usersStats'] = {}

  collect_stats_from_users(report, users)

  File.write('result.json', "#{report.to_json}\n")
  finish = Time.now

  diff = finish - start
  p diff
end
