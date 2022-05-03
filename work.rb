# frozen_string_literal: true

require 'ruby-progressbar'
require_relative 'task-1'

parts_of_work = 10

progressbar = ProgressBar.create(
  total: parts_of_work,
  format: '%a, %J, %E %B'
)

(1..parts_of_work).each do
  Parser.new.work('data_8000.txt')
  progressbar.increment
end

