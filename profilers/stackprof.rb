# frozen_string_literal: true

require 'stackprof'
require_relative '../task-1.rb'

StackProf.run(mode: :cpu, out: 'reports/stackprof.dump', interval: 1000) do
  work(filename: 'data_large12500.txt', gc: false)
end
