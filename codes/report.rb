require 'fileutils'
require "open4"
require_relative "task-1"

STEP = '4.0'

class Report
  attr_reader :type, :step, :folder

  def initialize(type)
    @type = type
    @step = STEP
    @folder = type.to_s
  end

  def full_name
    File.join(path, filename)
  end

  def file
    File.open(full_name, "w+")
  end

  def run
    work(data, disable_gc: true)
  end

  def save(body)
    file.write(body)
    body
  end

  def open
    command_run
  end

  private

  def command
    action = case type
             when :stackprof
               "stackprof"
             else
               "open"
             end
    "#{action} #{full_name}"
  end

  def test?
    type == :test
  end

  def command_run
    return if test?

    command_line = case type
                   when :test
                   when :stackprof
                          (<<-SHELL
                osascript -e 'tell app "Terminal" to do script "cd #{Dir.pwd}; #{command}; echo #{command} --method "'
                SHELL
                ).strip
                   else
                     command
                   end
    #`#{command_line}`
    system(command_line)
    puts command_line
  end

  def extension
    case type
    when :graph, :callstack
      ".html"
    when :stackprof
      ".dump"
    else
      ".txt"
    end
  end

  def data
    File.join('data', "#{data_filename}.txt")
  end

  def version
    File.read('.ruby-version').strip
  end

  def path
    path = File.join("reports", version, data_filename, folder)
    FileUtils.mkdir_p(path) unless Dir.exist? path
    path
  end

  def filename
    "#{step}#{extension}"
  end

  def data_filename
    case type
    when :test
      "test"
    else
      "100_000"
      #"800_000"
      #"1_600_000"
      #"large"
      #"small"
      #"medium"
    end
  end
end
