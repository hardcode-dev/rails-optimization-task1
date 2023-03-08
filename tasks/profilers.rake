# frozen_string_literal: true

require 'ruby-prof'
require 'stackprof'

require_relative '../task-1'
require_relative '../scripts/profilers_setup'

# rubocop:disable Metrics/BlockLength
namespace :profilers do
  desc 'On the specified amount of data, the specified ruby_prof profileler is called'
  task :ruby_prof, %i[lines_number profiler_name] => :environment do |_task, args|
    RubyProf.measure_mode = RubyProf::WALL_TIME

    file_path = profilers_setup(lines: args[:lines_number])
    result = RubyProf.profile { work(file_path: file_path, disable_gc: true) }

    case args[:profiler_name]
    when 'callgrind'
      printer = RubyProf::CallTreePrinter.new(result)
      printer.print(path: 'reports/ruby_prof', profile: 'callgrind')
    when 'callstack'
      printer = RubyProf::CallStackPrinter.new(result)
      printer.print(File.open('reports/ruby_prof/callstack.html', 'w+'))
    when 'flat'
      printer = RubyProf::FlatPrinter.new(result)
      printer.print(File.open('reports/ruby_prof/flat.txt', 'w+'))
    when 'graph'
      printer = RubyProf::GraphHtmlPrinter.new(result)
      printer.print(File.open('reports/ruby_prof/graph.html', 'w+'))
    else
      puts '!!! Something went wrong !!!'
    end
  end

  desc 'On the specified amount of data, the specified stack_prof profileler is called'
  task :stackprof, %i[lines_number profiler_name] => :environment do |_task, args|
    file_path = profilers_setup(lines: args[:lines_number])

    case args[:profiler_name]
    when 'cli'
      StackProf.run(mode: :wall, out: 'reports/stackprof/cli.dump', interval: 1000) do
        work(file_path: file_path, disable_gc: true)
      end
    when 'speeds'
      profile = StackProf.run(mode: :wall, raw: true) { work(file_path: file_path, disable_gc: true) }
      File.write('reports/stackprof/speeds.json', JSON.generate(profile))
    else
      puts 'Something went wrong'
    end
  end
end
# rubocop:enable Metrics/BlockLength
