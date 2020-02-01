require 'rspec-benchmark'
require_relative '../task-1'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end

describe 'Perfomance' do

  describe 'work' do
    it 'works under 1.33 sec' do
      expect { work }.to perform_under(1.33).sec
    end
  end

end
