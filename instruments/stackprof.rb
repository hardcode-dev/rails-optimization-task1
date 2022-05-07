# frozen_string_literal: true

require 'json'
require 'stackprof'
require_relative '../task_1'

GC.disable
profile = StackProf.run(mode: :wall, raw: true) do
  Parser.new('specs/fixtures/data_8000.txt')
end

File.write('instruments/stackprof_reports/stackprof.json', JSON.generate(profile))

GC.enable
