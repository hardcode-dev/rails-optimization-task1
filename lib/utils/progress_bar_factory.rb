require 'ruby-progressbar'

class ProgressBarFactory
    FORMAT= '%a, %J, %E %B'.freeze
    attr_accessor :total, :format, :output

    def initialize(total, format = FORMAT)
      @total = total
      @format = format
      @output = File.open(File::NULL, 'w') if ENV['ENVIRONMENT'] == 'test'  
    end

    def create
      ProgressBar.create(**build_params)
    end

    private

    def build_params
      {
        total:,
        format:,
        output:
      }.compact
    end
end