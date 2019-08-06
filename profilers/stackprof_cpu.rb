require 'stackprof'
require './task1'

StackProf.run(mode: :cpu, raw: true, out: 'profilers/stackprof/stackprof-cpu-myapp.dump') do
  work('spec/fixtures/1000_lines.txt')
end

# stackprof profilers/stackprof/stackprof-cpu-myapp.dump --text --limit 1
# stackprof tmp/stackprof-cpu-*.dump --method 'String#blank?'

## flamegraph
# stackprof --flamegraph profilers/stackprof/stackprof-cpu-myapp.dump > profilers/stackprof/flamegraph
# stackprof --flamegraph-viewer=tmp/flamegraph
