require 'benchmark'
require 'ruby-progressbar'
require 'ruby-prof'
require 'stackprof'
require 'json'

require_relative '../task-1'

def asymptotic_analysis
	GC.disable

	`head -n 1000 data_large.txt > data.txt`
	puts "1000 - #{Benchmark.realtime { work }}"

	`head -n 2000 data_large.txt > data.txt`
	puts "2000 - #{Benchmark.realtime { work }}"

	`head -n 4000 data_large.txt > data.txt`
	puts "4000 - #{Benchmark.realtime { work }}"

	`head -n 8000 data_large.txt > data.txt`
	puts "8000 - #{Benchmark.realtime { work }}"

	`head -n 16000 data_large.txt > data.txt`
	puts "16000 - #{Benchmark.realtime { work }}"

	`head -n 32000 data_large.txt > data.txt`
	puts "32000 - #{Benchmark.realtime { work }}"

	`head -n 64000 data_large.txt > data.txt`
	puts "64000 - #{Benchmark.realtime { work }}"

	`head -n 128000 data_large.txt > data.txt`
	puts "128000 - #{Benchmark.realtime { work }}"

	`head -n 256000 data_large.txt > data.txt`
	puts "256000 - #{Benchmark.realtime { work }}"

	`head -n 512000 data_large.txt > data.txt`
	puts "512000 - #{Benchmark.realtime { work }}"
end

def prepare_to_profile(gc_disable: true)
	# `head -n 400000 data_large.txt > data.txt`
	`cp data_large.txt data.txt`
	GC.disable if gc_disable
end

# def work_with_progressbar
# 	size = `wc -l data.txt`.split.first.to_i
# 	pb = ProgressBar.create(total: size, format: '%a, %J, %E %B')
# 	work { pb.increment }
# end

def benchmark
	prepare_to_profile(gc_disable: false)
	puts Benchmark.realtime { work }
end

def ruby_prof_profile
	prepare_to_profile
	RubyProf.measure_mode = RubyProf::WALL_TIME
	RubyProf.profile do
		work
	end
end

def flat_ruby_prof
	result = ruby_prof_profile
	printer = RubyProf::FlatPrinter.new(result)
	printer.print(STDOUT)
end

# open tmp/ruby_prof_reports/graph_report.html
def graph_ruby_prof
	result = ruby_prof_profile
	printer = RubyProf::GraphHtmlPrinter.new(result)
	printer.print(File.open('./tmp/ruby_prof_reports/graph_report.html', 'w+'))
end

# open tmp/ruby_prof_reports/call_stack_report.html
def call_stack_ruby_prof
	result = ruby_prof_profile
	printer = RubyProf::CallStackPrinter.new(result)
	printer.print(File.open('./tmp/ruby_prof_reports/call_stack_report.html', 'w+'))
end

# brew install qcachegrind
# qcachegrind tmp/ruby_prof_reports/callgrind...
def call_tree_ruby_prof
	result = ruby_prof_profile
	printer = RubyProf::CallTreePrinter.new(result)
	printer.print(path: 'tmp/ruby_prof_reports', profile: 'callgrind')
end

# stackprof tmp/stackprof_reports/stackprof.dump
# stackprof tmp/stackprof_reports/stackprof.dump --method work
def stack_prof_cli
	prepare_to_profile
	StackProf.run(mode: :wall, out: './tmp/stackprof_reports/stackprof.dump', interval: 1000) do
		work
	end
end

# https://www.speedscope.app/
def stack_prof_speedscope
	prepare_to_profile
	profile = StackProf.run(mode: :wall, raw: true, interval: 1000) do
		work
	end

	File.write('./tmp/stackprof_reportsspeedscope.json', JSON.generate(profile))
end

benchmark
flat_ruby_prof
graph_ruby_prof
call_stack_ruby_prof
call_tree_ruby_prof
stack_prof_cli
stack_prof_speedscope
asymptotic_analysis