# frozen_string_literal: true

require 'sorted_set'
require 'oj'

def work_new(file = 'data_storage/data_large.txt')
  users           = {}
  unique_browsers = SortedSet.new
  report          = {
    total_users: 0,
    total_sessions: 0,
    unique_browsers_count: 0,
    users_stats: {}
  }

  File.foreach(file, chomp: true) do |line|
    cols = line.split(',')
    users[cols[1]] ||= {
      sessions_count: 0,
      total_time: 0,
      longest_session: 0,
      browsers: [],
      used_ie: false,
      always_used_chrome: true,
      dates: []
    }

    user = users[cols[1]]

    if cols[0][0] == 'u'
      report[:total_users] += 1
      user[:full_name] = "#{cols[2]} #{cols[3]}"
    else
      report[:total_sessions] += 1
      unique_browsers.add(cols[3])
      time    = cols[4].to_i
      browser = cols[3]

      user[:sessions_count]     += 1
      user[:total_time]         += time
      user[:longest_session]    = time if user[:longest_session] < time
      user[:used_ie]            = browser[0] == 'I' unless user[:used_ie]
      user[:always_used_chrome] = browser[0] == 'C' if user[:always_used_chrome]
      user[:browsers].push(browser)
      user[:dates].push(cols[5])
    end
  end

  report[:all_browsers] = unique_browsers.map do |browser|
    report[:unique_browsers_count] += 1
    browser.upcase
  end.join(',')

  users.each do |_, data|
    report[:users_stats][data[:full_name]] = {
      sessions_count: data[:sessions_count],
      total_time: "#{data[:total_time]} min.",
      longest_session: "#{data[:longest_session]} min.",
      browsers: data[:browsers].join(', '),
      used_ie: data[:used_ie],
      always_used_chrome: data[:always_used_chrome],
      dates: data[:dates].sort { |a, b| b <=> a }
    }
  end

  File.write('result_new.json', "#{Oj.dump(report)}\n")
end
