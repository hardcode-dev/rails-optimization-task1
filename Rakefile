require 'rspec/core/rake_task'
require 'rake/testtask'
require 'benchmark'
#require_relative 'benchmark/ruby-prof'

task default: %i[benchmark_spec test ruby_prof stackprof processing_time]

task :benchmark_spec do
  RSpec::Core::RakeTask.new.run_task(true)
end

task :test do
  Rake::TestTask.new do |t|
    t.test_files = ['spec/user_test.rb']
  end
end

task :ruby_prof do
  ruby 'benchmark/ruby-prof.rb'
end

task :stackprof do
  ruby 'benchmark/stackprof.rb'
  system "stackprof benchmark/reports/stackprof.dump"
end

task :processing_time do
  ruby 'benchmark/processing_time.rb'
end
