require_relative '../task-1'

require 'stackprof'

profile = StackProf.run(mode: :wall, raw: true) do
  GC.disable
  work
end

File.write("tmp/stackprof/speedscope_#{Time.now.to_i}.json", JSON.generate(profile))
