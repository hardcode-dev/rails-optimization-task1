# frozen_string_literal: true

Dir.mkdir('tmp') unless Dir.exist?('tmp')

`rm tmp/data_*.txt`
`gunzip -c data_large.txt.gz > tmp/data_large.txt`

range = [1000, 2000, 4000, 8000, 10_000, 16_000, 20_000]

range.each do |n|
  `head -n #{n} tmp/data_large.txt > tmp/data_#{n}.txt`
end
