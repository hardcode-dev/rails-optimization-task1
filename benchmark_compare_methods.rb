# frozen_string_literal: true

require 'benchmark'

n = 100
arr = Array.new(10_000) { 'x' * 100 }

Benchmark.bmbm do |x|
  %i[count size].each do |method|
    x.report(method.to_s) do
      n.times do
        arr.send(method)
      end
    end
  end
end
# Rehearsal -----------------------------------------
# count   0.000015   0.000001   0.000016 (  0.000013)
# size    0.000009   0.000001   0.000010 (  0.000010)
# -------------------------------- total: 0.000026sec
#             user     system      total        real
# count   0.000011   0.000000   0.000011 (  0.000010)
# size    0.000009   0.000001   0.000010 (  0.000010)

Benchmark.bmbm do |x|
  x.report('123.to_s') do
    n.times do
      123.to_s
    end
  end

  # rubocop:disable all
  x.report('#{123}') do
    n.times do
      "#{123}"
    end
  end
  # rubocop:enable all
end
# Rehearsal --------------------------------------------
# 123.to_s   0.000009   0.000001   0.000010 (  0.000009)
# #{123}     0.000012   0.000000   0.000012 (  0.000012)
# ----------------------------------- total: 0.000022sec
#                user     system      total        real
# 123.to_s   0.000009   0.000000   0.000009 (  0.000008)
# #{123}     0.000011   0.000000   0.000011 (  0.000011)
