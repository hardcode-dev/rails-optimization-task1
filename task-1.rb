# frozen_string_literal: true

# Deoptimized version of homework task

require 'json'
require 'pry'
require 'date'

require_relative 'report/report'
require_relative 'report/parser'

require_relative 'report/v1/report'
require_relative 'report/v1/parser'

require_relative 'report/v2/report'
require_relative 'report/v2/parser'

require_relative 'report/v3/report'
require_relative 'report/v3/parser'

require_relative 'report/v4/report'
require_relative 'report/v4/parser'

GC.disable

class InitWork
  def self.work(file_name = 'data.txt')
    file_lines = File.read(file_name).split("\n")

    users, sessions = parse(file_lines)
    report = report(users, sessions)

    File.write('result.json', "#{report.to_json}\n")
  end
end

class WorkV1
  def self.work(file_name = 'data.txt')
    file_lines = File.read(file_name).split("\n")

    users, sessions, sessions_hash = V1.parse(file_lines)
    report = V1.report(users, sessions, sessions_hash)

    File.write('result.json', "#{report.to_json}\n")
  end
end

class WorkV2
  def self.work(file_name = 'data.txt')
    file_lines = File.read(file_name).split("\n")

    users, sessions, sessions_hash = V2.parse(file_lines)
    report = V2.report(users, sessions, sessions_hash)

    File.write('result.json', "#{report.to_json}\n")
  end
end

class WorkV3
  def self.work(file_name = 'data.txt')
    file_lines = File.read(file_name).split("\n")

    users, sessions, sessions_hash = V3.parse(file_lines)
    report = V3.report(users, sessions, sessions_hash)

    File.write('result.json', "#{report.to_json}\n")
  end
end

class WorkV4
  def self.work(file_name = 'data.txt')
    file_lines = File.read(file_name).split("\n")

    users, sessions, sessions_hash, sessions_br = V4.parse(file_lines)
    report = V4.report(users, sessions, sessions_hash, sessions_br)

    File.write('result.json', "#{report.to_json}\n")
  end
end
