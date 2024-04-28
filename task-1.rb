# Deoptimized version of homework task

require 'json'
require 'pry'
require 'date'
require_relative 'report/report'
require_relative 'report/parser'
GC.disable

def work(file_name = 'data.txt')
  file_lines = File.read(file_name).split("\n")

  users, sessions = parse(file_lines)
  report = report(users, sessions)

  File.write('result.json', "#{report.to_json}\n")
end
