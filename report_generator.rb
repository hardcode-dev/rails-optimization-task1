# frozen_string_literal: true

require 'benchmark'
require_relative './task-1'

SIZES = [1500, 3000, 6000, 12000].freeze

class ReportGenerator
  def call
    puts '| Объём | Время |'
    puts '| ------ | ------ |'
    SIZES.each do |size|
      setup_data(size)
      time = Benchmark.realtime { work }
      puts "| #{size} | #{time.round(2)} |"
      clear_data
    end
    puts '| ... | ... |'
    puts '|  N  | O(---) |'
  end

  private

  def setup_data(size)
    File.write('data.txt', File.read("spec/fixtures/data#{size}.txt"))
    File.write('result.json', '')
  end

  def clear_data
    File.delete('data.txt')
    File.delete('result.json')
  end
end

ReportGenerator.new.call
