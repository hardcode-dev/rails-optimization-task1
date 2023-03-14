bm:
	ruby benchmarking.rb

test:
	ruby test_me.rb

check:
	rspec performance.rb

prof-flat:
	ruby ruby_prof_flat.rb

prof-flat_read:
	cat ruby_prof_reports/flat.txt

prof-graph:
	ruby ruby_prof_graph.rb

prof-graph_read:
	open ruby_prof_reports/graph.html

prof-call_stack:
	ruby ruby_prof_call_stack.rb

prof-call_stack_read:
	open ruby_prof_reports/call_stack.html

prof-call_grind:
	ruby ruby_prof_grind.rb

prof-call_grind_read:
	qcachegrind ruby_prof_reports/callgrind.out.15532

stackprof:
	ruby stackprof.rb

# stackprof stackprof.dump --method Object#work
stackprof_read:
	cd stackprof_reports && stackprof stackprof.dump

stackprof_speedscope:
	ruby stackprof_speedscope.rb

# sudo rbspy record --pid 58587 # подключение к работающему процессу

.PHONY:	test
