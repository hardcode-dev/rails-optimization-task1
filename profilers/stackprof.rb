# frozen_string_literal: true

# Stackprof reports
# ruby stackprof.rb
# cd require_relative/reports/stackprof
# stackprof stackprof.dump
# stackprof stackprof.dump --method Object#work
# json flamegraph in https://www.speedscope.app

require 'stackprof'
require_relative '../task_1'

FILENAME_SMALL = 'data.txt'
FILENAME_2_500 = 'data_2_500.txt'
FILENAME_5_000 = 'data_5_000.txt'
FILENAME_10_000 = 'data_10_000.txt'
FILENAME_LARGE = 'data_large.txt'

filename = FILENAME_10_000
path = 'profilers/reports/stackprof'

# dump
StackProf.run(mode: :wall, out: "#{path}/stackprof.dump", interval: 1000) do
  work("data/#{filename}", disable_gc: true)
end

# json
profile = StackProf.run(mode: :wall, raw: true) do
  work("data/#{filename}", disable_gc: true)
end

File.write("#{path}/stackprof.json", JSON.generate(profile))
