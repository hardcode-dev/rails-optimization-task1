# brew install rbspy
# DATA_FILE=large.txt §ruby work.rb # запуск долгого процесса
# sudo rbspy record --pid 19587 # подключение к работающему процессу
# sudo rbspy record ruby my-script.rb # постоение flamegraph

# sudo su
# rbspy record ruby profilers/1_ruby_spy_run.rb

require_relative '../config/environment'

Task.new(dasable_gc: false).work

result_file_path = 'data/result.json'
File.delete(result_file_path) if File.exist?(result_file_path)
