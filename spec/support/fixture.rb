module Fixture
  def file_fixture(file_path)
    path = File.join(ENV["PWD"], "spec", "fixtures").to_s + "/" + file_path

    File.open(path)
  end
end
