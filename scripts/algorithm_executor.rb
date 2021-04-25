require 'benchmark'
require 'benchmark-trend'
require 'benchmark/ips'

require_relative '../task-1'
require_relative '../task-origin'
class AlgorithmExecutor
    attr_reader :trend, :trends, :data
    attr_accessor :data_size, :version

    def initialize name, version, data_size, saver, gc_disable=false
        @gc_disable = gc_disable 
        @name = name 
        @version = version
        @data_size = data_size
        @data = {get_fullname => {}}
        @saver = saver
    end

    def exec &block
        GC.disable if @gc_disable
        puts "start bench time"
        @time = Benchmark.realtime do 
            #yield([5, 4, 3, 1, 2]*1000)
            yield
        end.round(2)

        #puts "start bench trend"
        #numbers = Benchmark::Trend.range(100, 1000, ratio: 10)
        #@trend, @trends = Benchmark::Trend.infer_trend(numbers) do |n, i|
        #    puts n
        #    yield([5, 4, 3, 1, 2]*n)
        #end

        #Benchmark.ips do |x|
        #    x.report("slow string concatenation") do
        #        data.map { |row| row.join(",") }.join("\n")
        #    end
        #end

        @data[get_fullname] = @time
    end

    def get_fullname
        [@name, @version, @data_size].join('-')
    end

    def time
        @time
    end

    def save
        @saver.store(@data)
    end
end

class AlgorithmDataSaver
    def store data
        
    end
end

class AlgorithmDataSaverToFile
    def initialize filename
        @filename = filename
    end
    def store data
        open(@filename, 'a') { |f|
            f << "#{data.to_json}\n"
          }        
    end
end

require 'algorithms'

amount = 10000
a = AlgorithmExecutor.new("task-1","1", amount, AlgorithmDataSaverToFile.new("data/algo_perf.txt"))
while amount <= 40_000 do
    p amount
    a.data_size = amount 
    a.exec do |sample|
        #Algorithms::Sort.bubble_sort sample
        work("data/data#{amount}.txt")
    end
    amount = amount + 10000
end
a.version = "0"
amount = 10000
while amount <= 40_000 do 
    p amount
    a.data_size = amount
    a.exec do |sample|
        work_old("data/data#{amount}.txt")
    end
    amount = amount + 10000
end
a.save
puts a.data