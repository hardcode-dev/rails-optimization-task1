
require 'json'
require 'stackprof'
require_relative '../task-1'

profile = StackProf.run(mode: :wall, raw: true) do
  work('data/data-20000-lines.txt', false)
end

File.write('reports/stackprof.json', JSON.generate(profile))
