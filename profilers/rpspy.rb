# frozen_string_literal: true

# brew install rbspy
# DATA_FILE=data_large.txt ruby work.rb # запуск долгого процесса
# sudo rbspy record --pid 58587 # подключение к работающему процессу
# sudo rbspy record ruby my-script.rb # построение flamegraph

require_relative '../task_1'

work('data/data_10_000.txt', disable_gc: false)
