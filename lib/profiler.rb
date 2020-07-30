# frozen_string_literal: true

require 'stackprof'
require_relative '../task-1'

# stackprof stackprof_reports/stackprof.dump

# test_path_1k = 'files/data-1k'
test_path_10k = 'files/data-10k'
# test_path_20k = 'files/data-20k'
# test_path_100k = 'files/data-100k'
# test_path_300k = 'files/data-300k'

GC.disable

StackProf.run(mode: :wall, out: 'stackprof_reports/stackprof.dump', interval: 1000) do
  work(test_path_10k)
end
