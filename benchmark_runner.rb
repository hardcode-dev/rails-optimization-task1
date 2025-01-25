require_relative 'task-1'
require 'benchmark'

puts Benchmark.measure { work('data.txt') }
