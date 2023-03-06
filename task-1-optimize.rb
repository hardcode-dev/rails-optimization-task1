require "benchmark"

require_relative "./lib/user.rb"
  
GC.disable
Benchmark.bm(5) do |x|
  x.report   { work("./data_small.txt") }
end
GC.enable

class TestMe < Minitest::Test
  def test_result
    work("./data_small.txt")
    expected_result = File.read("./data_small_result.json")
    assert_equal expected_result, File.read('result.json')
  end
end