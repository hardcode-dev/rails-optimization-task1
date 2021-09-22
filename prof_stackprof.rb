# frozen_string_literal: true

require 'stackprof'
require_relative 'task_1'

StackProf.run(mode: :wall, out: 'ruby_prof_reports/stackprof.dump', interval: 1000) do
  work('data_small.txt', disable_gc: true)
end