lines = [2000, 4000, 6000, 8000, 10000, 12000, 14000, 16000, 18000, 20000]

lines.each do |line|
  `head -n #{line} data/data_large.txt > data/data-#{line}-lines.txt`
end
