require 'minitest/autorun'
require 'minitest/benchmark'
require './task-1.rb'
require './task-1-refactored.rb'

GC.disable

class BenchTest < MiniTest::Benchmark
  def bench_algorithm
    assert_performance_exponential do |n|
      algorithm(n)
    end
  end

  def algorithm(n)
    File.write('result.json', '')
    File.write('data.txt', '')
    File.write('data.txt',
               'user,1,Palmer,Katrina,65
session,1,0,Safari 17,12,2016-10-21
session,1,1,Firefox 32,3,2016-12-20
session,1,2,Chrome 6,59,2016-11-11
session,1,3,Internet Explorer 10,28,2017-04-29
session,1,4,Chrome 13,116,2016-12-28
' * n)
    Refactored.new.work('data.txt')
  end
end