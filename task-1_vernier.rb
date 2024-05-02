# frozen_string_literal: true

# rubocop:disable all
# gem 'vernier'
# gem 'profile-viewer'
<<-BASH
  DATA_FILE='data200_000.txt' DISABLE_GC=false ruby task-1_vernier.rb
  profile-viewer vernier/task-1_vernier_data_file_data200_000.txt_disable_gc_false.json
BASH
# rubocop:enable all

require 'vernier'
require_relative 'task-1'

params = "data_file_#{ENV.fetch('DATA_FILE', nil)}_disable_gc_#{ENV.fetch('DISABLE_GC', true)}"
Vernier.run(out: "vernier/task-1_vernier_#{params}.json") do
  work(ENV.fetch('DATA_FILE', nil), disable_gc: ENV.fetch('DISABLE_GC', true))
end
