require_relative '../work'
require 'benchmark'

puts Benchmark.measure { work("data/data#{ENV['FILE_SIZE']}.txt") }
