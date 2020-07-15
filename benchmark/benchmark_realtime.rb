# frozen_string_literal: true

require 'benchmark'
require_relative '../task-1'

def realtime(name = '', &block)
  time = Benchmark.realtime do
    block.call
  end

  puts "#{name} Finish in #{time.round(2)}"
end

%w[1000 2000 4000 8000 10000 16000 20000].each do |size|
  realtime(size) { work("tmp/data_#{size}.txt") }
end

# 1000 Finish in 0.03
# 2000 Finish in 0.08
# 4000 Finish in 0.27
# 8000 Finish in 0.94
# 10000 Finish in 1.43
# 16000 Finish in 3.37
# 20000 Finish in 5.14
#