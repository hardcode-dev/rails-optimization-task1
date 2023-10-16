# frozen_string_literal: true

FILES = {
  '1Mb' => 1_048_576,
  '2Mb' => 2_097_152,
  '3Mb' => 3_145_728,
  '4Mb' => 4_194_304,
  '5Mb' => 5_242_880
}.freeze

FILES.each do |name, size|
  copied = 0
  source = File.open('./data_large.txt')
  test_file = File.open("./profiling/files/data_#{name}", 'w+')
  while (line = source.gets)
    break if copied >= size

    test_file.puts line
    copied += line.size
  end
ensure
  source.close
  test_file.close
end
