module ApplicationLoader
  extend self

  def load_app!
    require_dir 'app'
  end

  def root
    File.expand_path('..', __dir__)
  end

  private

  def require_dir(path)
    path = File.join(root, path)
    Dir["#{path}/**/*.rb"].each { |file| require file }
  end
end
