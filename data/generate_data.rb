lines = [100_000, 200_000, 400_000, 600_000]

lines.each do |line|
  `head -n #{line} data/data_large.txt > data/data-#{line}-lines.txt`
end
