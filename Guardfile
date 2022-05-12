guard :shell do
  watch('task-1.rb') do |_m|
    system('ruby ./profiling/ruby-prof_graph.rb')
    system('ruby ./profiling/ruby-prof_callstack.rb')
    system('ruby ./benchmarking/bm.rb')
  end
end

guard :minitest do
  # with Minitest::Unit
  watch('test/task-1_test.rb')
  watch('task-1.rb') { |_m| 'test/task-1_test.rb' }
end

guard :rspec, cmd: 'rspec -f doc' do
  watch('spec/task-1_spec.rb')
  watch('task-1.rb') { |_m| 'spec/task-1_spec.rb' }
end
