# frozen_string_literal: true

require 'json'
require 'stackprof'
require_relative '../task_1'

profile = StackProf.run(mode: :wall, raw: true) do
  work(disable_gc: true)
end

File.write('reports/stackprof.json', JSON.generate(profile))
