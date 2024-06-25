require 'benchmark'
require 'lazy'
require_relative 'task-1'

# array = (1..10000000).to_a

# def eqeq_test(array)
#   array.select { |el| el == 500000 }
# end

# def include_test(array)
#   array.include?(500000)
# end

# def in_test(array)
#   500000.in?(array)
# end
# def map_test(array)
#     array.map { |el| el % 10 == 0 ? el : nil }.compact
# end

# def test_select(array)
#     array.select { |el| el % 10 == 0 }
# end

# def test_reject(array)
#     array.reject { |el| el % 10 == 0 }
# end

# def test_slice(array)
#     array.slice_after { |element| element % 10 == 0 }.to_a
# end

# def test_lazy(array)
#     array.lazy.select { |el| el % 10 == 0 }
# end

# def test_set(array)
#     array.to_set.select { |el| el % 10 == 0 }
# end

# Benchmark.bm do |benchmark|
#   benchmark.report('eqeq') { eqeq_test(array) }
#   benchmark.report('include') { include_test(array) }
#   benchmark.report('in') { in_test(array) }
# end