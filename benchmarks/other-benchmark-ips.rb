require 'benchmark/ips'

Benchmark.ips do |x|

  a = (0..100_000).to_a
  b = (0..100_000).to_a

  x.report("reject") do
    a.reject!(&:succ)
  end

  x.report('while') do
    b.each do |x|
      x.succ
      b.delete(x)
    end

  end

  x.compare!
end
