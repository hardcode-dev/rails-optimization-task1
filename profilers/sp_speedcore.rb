require 'stackprof'
require 'json'
require_relative '../task-1.rb'

profile = StackProf.run(mode: :wall, raw: true) do
  work(filename: 'test_data/data100000.txt', gc_disabled: $gc)
end

File.write('tmp/stackprof-speedscore.json', JSON.generate(profile))
