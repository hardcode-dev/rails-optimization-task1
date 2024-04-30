rm -rf ruby_prof_reports stackprof_reports
mkdir ruby_prof_reports stackprof_reports
DATA_FILE='data200_000.txt' DISABLE_GC=false ruby task-1_ruby_prof_flat.rb
DATA_FILE='data200_000.txt' DISABLE_GC=false ruby task-1_ruby_prof_graph.rb
DATA_FILE='data200_000.txt' DISABLE_GC=false ruby task-1_ruby_prof_callstack.rb
DATA_FILE='data200_000.txt' DISABLE_GC=false ruby task-1_ruby_prof_callgrind.rb
DATA_FILE='data200_000.txt' DISABLE_GC=false ruby task-1_stackprof_cli.rb
DATA_FILE='data200_000.txt' DISABLE_GC=false ruby task-1_stackprof_flamegraph.rb
ruby task-1_test.rb