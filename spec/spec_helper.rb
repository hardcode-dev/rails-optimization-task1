require 'rspec-benchmark'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers

  RSpec::Benchmark.configure do |config|
    config.run_in_subprocess = true
    config.disable_gc = false
  end
end