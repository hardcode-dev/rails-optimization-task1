require 'stackprof'
require_relative '../task-1.rb'

StackProf.run(mode: :wall, out: 'tmp/stackprof-cli.dump', interval: 1000) do
  work(filename: 'test_data/data100000.txt', gc_disabled: $gc)
end
