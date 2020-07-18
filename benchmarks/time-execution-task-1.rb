require_relative '../lib/task-1'
require 'benchmark'

Benchmark.bmbm do |x|
  x.report('execution method work with 1000 lines') do
    work('data_1000.txt')
  end

  x.report('execution method work with 2000 lines') do
    work('data_2000.txt')
  end

  x.report('execution method work with 4000 lines') do
    work('data_4000.txt')
  end

  x.report('execution method work with 8000 lines') do
    work('data_8000.txt')
  end

  x.report('execution method work with 16000 lines') do
    work('data_16000.txt')
  end
end
