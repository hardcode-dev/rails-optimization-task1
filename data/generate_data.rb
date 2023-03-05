lines = [20000, 40000, 60000, 80000, 100_000]

lines.each do |line|
  `head -n #{line} data/data_large.txt > data/data-#{line}-lines.txt`
end
