require './task-1.rb'

describe "Perfomance" do
  describe 'work' do
    it 'works 20_000 under 4 s' do
      expect {
        work('data/data_20_000.txt', disable_gc: true)
      }.to perform_under(4).sec.warmup(2).times
    end

    it 'perform power' do
      expect { work('data/data_20_000.txt', disable_gc: true) }.to perform_power
    end
  end

end
