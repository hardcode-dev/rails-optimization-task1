require 'stackprof'

StackProf.run(mode: :wall, out: 'reports/stackprof-cli.dump', interval: 1000) do
  puts 'StackProf Cli'
  work($filename, gc: $gc)
end