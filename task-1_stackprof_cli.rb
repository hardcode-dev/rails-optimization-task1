# frozen_string_literal: true

require 'stackprof'
require_relative 'task-1'

# rubocop:disable all
<<-BASH
  DATA_FILE='data5000.txt' DISABLE_GC=true ruby task-1_stackprof_cli.rb
  DATA_FILE='data20000.txt' DISABLE_GC=true ruby task-1_stackprof_cli.rb
  stackprof stackprof_reports/stackprof_cli_data_file_data10000.txt_disable_gc_true.dump
  stackprof stackprof_reports/stackprof_cli_data_file_data10000.txt_disable_gc_true.dump --method Array.all
  stackprof stackprof_reports/stackprof_cli_data_file_data10000.txt_disable_gc_true.dump --method Date.parse
  stackprof stackprof_reports/stackprof_cli_data_file_data10000.txt_disable_gc_true.dump --method String.split
BASH
# rubocop:enable all


params = "data_file_#{ENV.fetch('DATA_FILE', nil)}_disable_gc_#{ENV.fetch('DISABLE_GC', true)}"

StackProf.run(mode: :wall, out: "stackprof_reports/stackprof_cli_#{params}.dump", interval: 1000) do
  work(ENV.fetch('DATA_FILE', nil), disable_gc: ENV.fetch('DISABLE_GC', true))
end
