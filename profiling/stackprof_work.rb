# frozen_string_literal: true

require 'stackprof'
require_relative '../task-1'

=begin
StackProf.run(mode: :wall, out: 'profiling/stackprof_work.dump', interval: 1000, disable_gc: true) do
  work(file_path: 'data_25000_thousands_lines.txt')
end
=end

### stackprof speedscope

profiling = StackProf.run(model: :wall, raw: true, disable_gc: true) do
  work(file_name: 'data_large.txt')
end

File.write('profiling/stackprof_speedscope_3_million_250_thousand_v2.json', JSON.generate(profiling))
