require "ruby-prof"

require_relative "../task-1"

RubyProf.measure_mode = RubyProf::WALL_TIME

file_name = ENV["FILE_NAME"] || "data.txt"
file_path = File.join(ENV["PWD"], "spec", "fixtures", "data", file_name)

result = RubyProf.profile {
  report = Report.new(file_path)
  report.work
}

reports_path = File.join(ENV["PWD"], "reports")

printer = RubyProf::MultiPrinter.new(result)
printer.print(path: reports_path, profile: "profile")
