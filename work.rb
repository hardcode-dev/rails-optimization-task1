require_relative 'task-1.rb'

file = ENV['DATA_FILE'] || 'data_large.txt'

work(
  file: file,
  disable_gc: false,
  progressbar_use: false
)