class ArtifactCleaner
  class << self
    def clean(path)
      File.delete(path) if File.exist?(path)
    end
  end
end