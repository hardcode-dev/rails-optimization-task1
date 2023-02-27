#!/usr/bin/env bash

set -e

ruby task-1_test.rb
ruby task-1_bench.rb
ruby task-1_ruby-prof.rb
ruby task-1_stackprof.rb
stackprof reports/stackprof-cpu.dump --text > reports/stackprof-cpu.txt
stackprof --d3-flamegraph reports/stackprof-cpu.dump > reports/flamegraph.html
rm result.json