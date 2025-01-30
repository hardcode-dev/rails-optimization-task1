class Bar
  attr_reader :parts_of_work

  def initialize(parts_of_work)
    @parts_of_work = parts_of_work
  end

  def progress
    ProgressBar.create(
      total: parts_of_work,
      format: '%a, %J, %E %B' # elapsed time, percent complete, estimate, bar
    # output: File.open(File::NULL, 'w') # IN TEST ENV
    )
  end
end
