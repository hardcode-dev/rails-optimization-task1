# frozen_string_literal: true

# lines - number of lines in the file being tested
def profilers_setup(lines: 8000)
  file_path = "data/data-#{lines}-lines.txt"

  # generate data for profilers
  `head -n #{lines} data/data_large.txt > #{file_path}`

  # create directories for profilers reports
  reports_dir = File.expand_path('../reports', __dir__)
  ruby_prof_dir = File.join(reports_dir, 'ruby_prof')
  stackprof_dir = File.join(reports_dir, 'stackprof')
  Dir.mkdir(reports_dir) unless Dir.exist?(reports_dir)
  Dir.mkdir(ruby_prof_dir) unless Dir.exist?(ruby_prof_dir)
  Dir.mkdir(stackprof_dir) unless Dir.exist?(stackprof_dir)

  # return file_path of test data for use in the profiler
  file_path
end
