require 'json'
require 'stackprof'

profile = StackProf.run(mode: :wall, raw: true) do
  puts 'StackProf speedscore'
  work($filename, gc: $gc)
end

File.write('reports/stackprof-speedscore.json', JSON.generate(profile))