# frozen_string_literal: true

# git clone https://github.com/brendangregg/FlameGraph.git
# stackprof stackprof_reports/stackprof_flamegraph_data_file_data20000.txt_disable_gc_true.json > stackprof_reports/stackprof_flamegraph_data_file_data20000.txt_disable_gc_true.folded
# ../FlameGraph/flamegraph.pl stackprof_reports/stackprof_flamegraph_data_file_data20000.txt_disable_gc_true.folded > stackprof_reports/stackprof_flamegraph_data_file_data20000.txt_disable_gc_true.svg

require 'json'
require 'stackprof'
require_relative 'task-1'

# rubocop:disable all
<<-BASH
  DATA_FILE='data5000.txt' DISABLE_GC=true ruby task-1_stackprof_flamegraph.rb
  DATA_FILE='data20000.txt' DISABLE_GC=true ruby task-1_stackprof_flamegraph.rb
BASH
# rubocop:enable all
# https://www.speedscope.app

profile = StackProf.run(mode: :wall, raw: true) do
  work(ENV.fetch('DATA_FILE', nil), disable_gc: ENV.fetch('DISABLE_GC', true))
end

params = "data_file_#{ENV.fetch('DATA_FILE', nil)}_disable_gc_#{ENV.fetch('DISABLE_GC', true)}"
File.write("stackprof_reports/stackprof_flamegraph_#{params}.json", JSON.generate(profile))
