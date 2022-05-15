require_relative 'task-1'

file_name = ENV['FILE_NAME'] || 'data.txt'
puts 'Start'
work(file_name: file_name, disabled_gc: true)