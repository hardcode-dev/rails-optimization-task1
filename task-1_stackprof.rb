# frozen_string_literal: true

require 'stackprof'
require_relative 'task-1'

StackProf.run(mode: :wall, out: 'reports/stackprof-cpu.dump', raw: true) { work('data_256k.txt') }
