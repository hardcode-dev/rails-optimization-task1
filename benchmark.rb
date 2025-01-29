require 'benchmark'
require_relative 'task-1.rb'

def benchmarked_work
  # GC.disable
  i = 4194304

  while File.exists?("data/data_#{i}.txt")
    filename = "data/data_#{i}.txt"

    puts "---------------------"
    time = Benchmark.realtime do
      work(filename)
    end

    puts "Finished in #{time.round(5)}"

    i = i * 2
  end
end

benchmarked_work
