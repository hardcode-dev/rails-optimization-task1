#!/usr/bin/env ruby

require_relative 'task-1.rb'
# require 'bundler/setup'

# require 'benchmark'

# Benchmark.bm do |x|
#   x.report { work('sample100.txt') }
#   x.report { work('sample1000.txt') }
#   x.report { work('sample10000.txt') }
# end

work('data_large.txt')
