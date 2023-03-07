# frozen_string_literal: true

AVAILABLE_FILE_SIZES = [1_000, 2_000, 4_000, 8_000, 16_000, 32_000, 64_000, 128_000].freeze

AVAILABLE_FILE_SIZES.each do |line|
  `head -n #{line} data/data_large.txt > data/data-#{line}-lines.txt`
end
