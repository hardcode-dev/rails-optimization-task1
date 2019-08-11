require 'pry'
require 'benchmark/ips'
require_relative '../helpers/sessions.rb'
require_relative '../task-1.rb'

user = { "id" => "694" }

file_lines = File.read('data/data_256x.txt').split("\n")
sessions = []

file_lines.each do |line|
  cols = line.split(',')
  sessions = sessions + [parse_session(line)] if cols[0] == 'session'
end


Benchmark.ips do |x|
  x.config(
    stats: :bootstrap,
    confidence: 95
  )
  x.report('#get_user_sessions') do
    get_user_sessions(sessions, user)
  end
end

