require 'minitest/autorun'
require 'minitest/benchmark'
require './01-task-1.rb'
require './02-task-1-refactored.rb'

GC.disable

class BenchTest < MiniTest::Benchmark
  def bench_algorithm
    assert_performance_linear do |n|
      algorithm(n)
    end
  end

  def algorithm(n)
    user_id = 1 + n
    File.write('result.json', '')
    File.write('data.txt', '')
    File.write('data.txt',
               "user,#{user_id},Palmer,Katrina,65
session,#{user_id},0,Safari 17,12,2016-10-21
session,#{user_id},1,Firefox 32,3,2016-12-20
session,#{user_id},2,Chrome 6,59,2016-11-11
session,#{user_id},3,Internet Explorer 10,28,2017-04-29
session,#{user_id},4,Chrome 13,116,2016-12-28
" * n)
    Refactored.new.work('data.txt')
  end
end