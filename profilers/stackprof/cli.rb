# frozen_string_literal: true

require 'stackprof'

require_relative '../../task-1'
require_relative '../../scripts/profilers_setup'

file_path = profilers_setup

StackProf.run(mode: :wall, out: 'reports/stackprof/cli.dump', interval: 1000) do
  work(file_path: file_path, disable_gc: true)
end
