require 'ruby-prof'
require 'stackprof'
require 'json'
require_relative '../task-1'

format = ARGV[0]



def build_format(format)
  RubyProf.measure_mode = RubyProf::WALL_TIME

  result = RubyProf.profile do
    work('fixtures/data100000.txt', true)
  end

  case format
  when 'flat'
    RubyProf::FlatPrinter.new(result).print(File.open('reports/flat.txt', 'w+'))
  when 'graph'
    RubyProf::GraphHtmlPrinter.new(result).print(File.open('reports/graph.html', 'w+'))
  when 'callstack'
    RubyProf::CallStackPrinter.new(result).print(File.open('reports/callstack.html', 'w+'))
  when 'callgrind'
    # qcachegrind reports/
    RubyProf::CallTreePrinter.new(result).print(:path => 'reports', :profile => 'callgrind')
  when 'stack-prof-cli'
    # stackprof reports/stackprof.dump
    # stackprof reports/stackprof.dump --method Object#work
    StackProf.run(mode: :wall, out: 'reports/stackprof.dump', interval: 1000) do
      work('fixtures/data100000.txt', true)
    end
  when 'stack-prof-json'
    profile = StackProf.run(mode: :wall, raw: true) do
      work('fixtures/data100000.txt', true)
    end
    File.write('reports/stackprof.json', JSON.generate(profile))
  else
    puts("Unknow format #{format}")
  end
end


build_format(format)
