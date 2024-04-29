require_relative '../task-1'

require 'stackprof'

StackProf.run(mode: :wall, out: "tmp/stackprof/cli_#{Time.now.to_i}.dump", interval: 1000) do
  GC.disable
  work
end
