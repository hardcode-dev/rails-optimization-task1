# frozen_string_literal: true

require 'benchmark/ips'
require 'date'

STRING = '2018-03-21'

def strftime
  Date.strptime(STRING, '%Y-%m-%d')
end

def iso
  Date.iso8601(STRING)
end

Benchmark.ips do |x|
  x.report('Date#iso8601') { iso }
  x.report('Date#strftime') { strftime }

  x.compare!
end
