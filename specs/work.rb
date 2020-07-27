# frozen_string_literal: true

require_relative '../task-1'

class Work < Minitest::Test
  ROWS_COUNT = 7500
  FILENAME = "data#{ROWS_COUNT}.txt"

  def setup
    `head -n #{ROWS_COUNT} data_large.txt > #{FILENAME}`
  end

  def test_result
    work(filename: FILENAME)

    `rm #{FILENAME}`
  end
end
