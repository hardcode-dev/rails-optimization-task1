run:
	ruby bin/runner

unzip:
	gzip -dk fixtures/data_large.txt.gz

prepare_data:
	head -n 1000 fixtures/data_large.txt > fixtures/data1000.txt
	head -n 2000 fixtures/data_large.txt > fixtures/data2000.txt
	head -n 4000 fixtures/data_large.txt > fixtures/data4000.txt
	head -n 8000 fixtures/data_large.txt > fixtures/data8000.txt
	head -n 100000 fixtures/data_large.txt > fixtures/data100000.txt

test:
	ENVIRONMENT=test ruby tests/task-1_test.rb

perform_test:
	ENVIRONMENT=test rspec tests/task_perform_spec.rb

all_tests:
	make test
	make perform_test

simple_benchmark:
	ENVIRONMENT=test ruby lib/benchmarks/simple_benchmarks.rb

simple_benchmark_gb_dis:
	ruby lib/benchmarks/simple_benchmarks.rb true

benchmarks_ips:
	ruby lib/benchmarks/benchmarks_ips.rb

benchmarks_ips_gb_dis:
	ruby lib/benchmarks/benchmarks_ips.rb true

report:
	ruby lib/reporters/prof_reporter.rb $(T)

all_reports:
	make report T='flat'
	make report T='graph'
	make report T='callstack'
	make report T='callgrind'
	make report T='stack-prof-cli'
	make report T='stack-prof-json'

.PHONY: test
