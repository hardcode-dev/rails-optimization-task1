require 'pry'

lines = 18
base = 2

while base <= 512
  counter = lines * grade
  result = []
  file = File.open("data_#{grade}x.txt", 'w+')

  File.open('data_large.txt', 'r') do |f|
    while counter > 0
      file.puts f.gets
      counter -= 1
    end
  end

  file.close
  base *= 2
end
