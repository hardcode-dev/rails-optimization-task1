# frozen_string_literal: true

# Deoptimized version of homework task

require 'json'
require 'pry'
require 'date'

require_relative 'report/v1/report'
require_relative 'report/v1/parser'

GC.disable

class WorkV1
  def self.work(file_name = 'data.txt')
    file_lines = File.read(file_name).split("\n")

    users, sessions, sessions_hash = V1.parse(file_lines)
    report = V1.report(users, sessions, sessions_hash)

    File.write('result.json', "#{report.to_json}\n")
  end
end
