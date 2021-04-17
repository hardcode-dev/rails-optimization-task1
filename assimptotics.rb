# frozen_string_literal: true

require_relative 'task-1'
FILENAME = 'data_assimpt.txt'

log = ['Assimptotics results:']

#%w[1000 10000 20000 30000 40000 50000 60000 70000 80000 90000 100000].each do |num_rows|
%w[30000 50000 100000 500000].each do |num_rows|
  puts "Started #{num_rows}"
  if system("head -n #{num_rows} data_large.txt > #{FILENAME}") && (`wc -l < #{FILENAME}`.strip == num_rows)
    start_time = Time.now.to_i
    work(FILENAME)
    log << "#{num_rows}: #{Time.now.to_i - start_time} sec;"
  end
  File.delete(FILENAME) if File.exist?(FILENAME)
end

puts log
