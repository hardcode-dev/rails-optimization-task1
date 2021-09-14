# frozen_string_literal: true

class DataManager
  class << self
    def setup_data(size = nil)
      File.write('data.txt', File.read("spec/fixtures/data#{size}.txt"))
      File.write('result.json', '')
    end

    def clear_data
      File.delete('data.txt')
      File.delete('result.json')
    end
  end
end
