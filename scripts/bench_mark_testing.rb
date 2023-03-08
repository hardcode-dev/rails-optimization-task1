# frozen_string_literal: true

require 'benchmark'

require_relative '../task-1'
require_relative 'generate_data'

def time(name, &block)
  time = Benchmark.realtime { block.call }

  puts "#{name} lines Completed in #{time.round(3)} sec"
end

AVAILABLE_FILE_SIZES.freeze.each do |lines|
  time(lines) { work(file_path: "data/data-#{lines}-lines.txt", disable_gc: false) }
end
