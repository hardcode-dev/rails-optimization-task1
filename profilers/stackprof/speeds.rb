# frozen_string_literal: true

require 'json'
require 'stackprof'

require_relative '../../task-1'
require_relative '../../scripts/profilers_setup'

file_path = profilers_setup

profile = StackProf.run(mode: :wall, raw: true) { work(file_path: file_path, disable_gc: true) }
File.write('reports/stackprof/speeds.json', JSON.generate(profile))
