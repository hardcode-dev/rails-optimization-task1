#rbspy record bundle exec -- ruby task1.rb

# brew install rbspy
# DATA_FILE=large.txt ruby work.rb # запуск долгого процесса
# sudo rbspy record --pid 58587 # подключение к работающему процессу
# sudo rbspy record ruby my-script.rb # постоение flamegraph

# sudo rbspy record bundle exec -- ruby -e 'require "./task1"; work("spec/fixtures/data_large.txt")'

#TBD on another pc
