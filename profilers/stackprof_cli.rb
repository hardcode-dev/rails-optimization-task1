# frozen_string_literal: true

require 'stackprof'
require_relative '../task_1'

StackProf.run(mode: :wall, out: 'reports/stackprof.dump', interval: 1000) do
  work(disable_gc: true)
end
