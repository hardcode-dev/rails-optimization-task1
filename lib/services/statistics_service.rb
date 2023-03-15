# frozen_string_literal: true

require "json"
require "date"

class StatisticsService
  def initialize(data_file_path)
    @data_file_path = data_file_path
  end

  # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity
  def work
    users = []
    sessions = []
    browsers = []

    File.readlines(data_file_path, chomp: true).each do |line|
      cols = line.split(",")

      next users << parse_user(cols) if cols[0] == "user"

      session = parse_session(cols)
      browsers << session["browser"]
      sessions << session
    end

    grouped_sessions = sessions.group_by { |session| session["user_id"] }
    unique_browsers = browsers.uniq.sort

    report = {}
    report[:totalUsers] = users.count
    report["uniqueBrowsersCount"] = unique_browsers.count
    report["totalSessions"] = sessions.count
    report["allBrowsers"] = unique_browsers.join(",")
    report["usersStats"] = {}

    users.each do |user|
      user_key = "#{user['first_name']} #{user['last_name']}"
      user_sessions = grouped_sessions[user["id"]]

      times = user_sessions.map { |user_session| user_session["time"] }
      browsers = user_sessions.map { |user_session| user_session["browser"] }
      dates = user_sessions.map { |user_session| user_session["date"] }

      sessions_count = user_sessions.count
      total_time = times.sum
      longest_session = times.max
      used_ie = browsers.any? { |b| b.include?("INTERNET EXPLORER") }
      always_used_chrome = used_ie ? false : browsers.all? { |b| b.include?("CHROME") }

      report["usersStats"][user_key] = {
        "sessionsCount" => sessions_count,
        "totalTime" => "#{total_time} min.",
        "longestSession" => "#{longest_session} min.",
        "browsers" => browsers.sort.join(", "),
        "usedIE" => used_ie,
        "alwaysUsedChrome" => always_used_chrome,
        "dates" => dates.sort.reverse
      }
    end

    File.write("#{Dir.pwd}/tmp/result.json", "#{report.to_json}\n")
  end
  # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity

  private

  attr_reader :data_file_path

  def parse_user(cols)
    {
      "id" => cols[1],
      "first_name" => cols[2],
      "last_name" => cols[3],
      "age" => cols[4]
    }
  end

  def parse_session(cols)
    {
      "user_id" => cols[1],
      "session_id" => cols[2],
      "browser" => cols[3].upcase,
      "time" => cols[4].to_i,
      "date" => cols[5]
    }
  end
end
