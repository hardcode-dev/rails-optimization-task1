require 'rspec-benchmark'
require_relative '../task-1-new'

RSpec.describe NewWork do
  include_examples 'works'

  describe 'speed' do
    include_examples 'speed' do
      let(:size) { 1000 }
      let(:ms) { 40 }
      let(:ips) { 25 }
    end
  end
end
