require 'rspec-benchmark'
require 'fileutils'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers

  def fixtures_path
    File.expand_path(File.join(__dir__, 'fixtures'))
  end

  def root_path
    File.expand_path(File.join(__dir__, '../'))
  end

  def prepare_data(data_size)
    filename = "#{fixtures_path}/sample.txt"

    `head -n #{data_size} #{root_path}/data_large.txt > #{filename}`

    yield filename
  ensure
    FileUtils.rm(filename)
  end
end
