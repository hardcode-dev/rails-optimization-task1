def full_path(path, base = '/Users/i.udalov/Projects/thinknetica/ror_optimization/rails-optimization-task1')
  File.expand_path(path, base)
end

def fixture(size)
  full_path("spec/fixtures/data#{size}.txt")
end

def ensure_test_data_exists(n)
  test_file = fixture(n)
  source_file =  full_path("data_large.txt")
  `if [ ! -f #{test_file} ]; then head -n #{n} #{source_file} > #{test_file}; fi`
end
