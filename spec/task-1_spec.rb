require './task-1.rb'

describe "Perfomance" do
  describe 'work' do
    it 'works 20_000 under 6 s' do
      expect {
        work('data/data_200_000.txt', disable_gc: false)
      }.to perform_under(6000).ms
    end

    it 'perform power' do
      expect { work('data/data_20_000.txt', disable_gc: false) }.to perform_power
    end
  end

end
