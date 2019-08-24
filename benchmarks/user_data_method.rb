require 'benchmark/ips'
require_relative './benchmark_suite.rb'
require_relative '../task-1.rb'

user_sessions = [{"user_id"=>"0", "session_id"=>"2", "browser"=>"Internet Explorer 28", "time"=>"31", "date"=>"2017-03-28"}, {"user_id"=>"0", "session_id"=>"1", "browser"=>"Firefox 12", "time"=>"118", "date"=>"2017-02-27"}, {"user_id"=>"0", "session_id"=>"0", "browser"=>"Safari 29", "time"=>"87", "date"=>"2016-10-23"}, {"user_id"=>"0", "session_id"=>"3", "browser"=>"Internet Explorer 28", "time"=>"109", "date"=>"2016-09-15"}, {"user_id"=>"0", "session_id"=>"4", "browser"=>"Safari 39", "time"=>"104", "date"=>"2017-09-27"}, {"user_id"=>"0", "session_id"=>"5", "browser"=>"Internet Explorer 35", "time"=>"6", "date"=>"2016-09-01"}]
user_attributes = {"id"=>"0", "first_name"=>"Leida", "last_name"=>"Cira", "age"=>"0"}

user = User.new(attributes: user_attributes, sessions: user_sessions)

suite = GCSuite.new

Benchmark.ips do |x|
  x.config(
    stats: :bootstrap,
    confidence: 95,
    suite: suite
  )

  x.report('#user_data slow') do
    {
      'sessionsCount' => user.sessions.count,
      'totalTime' => user.sessions.map {|s| s['time']}.map {|t| t.to_i}.sum.to_s + ' min.',
      'longestSession' => user.sessions.map {|s| s['time']}.map {|t| t.to_i}.max.to_s + ' min.',
      'browsers' => user.sessions.map {|s| s['browser']}.map {|b| b.upcase}.sort.join(', '),
      'usedIE' => user.sessions.map{|s| s['browser']}.any? { |b| b.upcase =~ /INTERNET EXPLORER/ },
      'alwaysUsedChrome' => user.sessions.map{|s| s['browser']}.all? { |b| b.upcase =~ /CHROME/ },
      'dates' => user.sessions.map{|s| s['date']}.map {|d| Date.parse(d)}.sort.reverse.map { |d| d.iso8601 }
    }
  end

  x.report('#user_data fast') do
    sessions_time = user.sessions.map {|s| s['time'].to_i }
    browsers = user.sessions.map{ |s| s['browser'].upcase }
    browsers_string = browsers.sort.join(', ')
    {
      'sessionsCount'    => user.sessions.count,
      'totalTime'        => "#{sessions_time.sum.to_s} min.",
      'longestSession'   => "#{sessions_time.max.to_s} min.",
      'browsers'         => browsers_string,
      'usedIE'           => browsers_string.match?('INTERNET'),
      'alwaysUsedChrome' => !browsers.any? { |b| !b.include?('CHROME') },
      'dates'            => user.sessions.map{|s| s['date'] }.sort!.reverse!
    }
  end

  x.compare!
end
