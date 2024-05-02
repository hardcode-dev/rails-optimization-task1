#!/bin/bash

# shellcheck disable=SC2046

filename="data200_000.txt"
disable_gc=false

# Создание директорий
rm -rf ruby_prof_reports stackprof_reports rbspy
mkdir ruby_prof_reports stackprof_reports rbspy

# Запуск rbspy для профилирования
ruby task-1_benchmark_large.rb $filename \
| sudo rbspy record --pid $(pgrep -f "ruby.*task-1_benchmark_large.rb") --format speedscope \
 --file "rbspy/task-1_flamegraph_data_file_${filename%.txt}_disable_gc_${disable_gc}.json"

# Запуск Ruby Prof для различных отчетов
DISABLE_GC=$disable_gc DATA_FILE=$filename ruby task-1_ruby_prof_flat.rb
DISABLE_GC=$disable_gc DATA_FILE=$filename ruby task-1_ruby_prof_graph.rb
DISABLE_GC=$disable_gc DATA_FILE=$filename ruby task-1_ruby_prof_callstack.rb
DISABLE_GC=$disable_gc DATA_FILE=$filename ruby task-1_ruby_prof_callgrind.rb
DISABLE_GC=$disable_gc DATA_FILE=$filename ruby task-1_ruby_prof_flamegraph.rb

# Запуск StackProf для различных отчетов
DISABLE_GC=$disable_gc DATA_FILE=$filename ruby task-1_stackprof_cli.rb
DISABLE_GC=$disable_gc DATA_FILE=$filename ruby task-1_stackprof_flamegraph.rb
DISABLE_GC=$disable_gc DATA_FILE=$filename ruby task-1_stackprof_flamegraph.rb

# Запуск тестов
ruby task-1_test.rb
