$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "rails_uploads/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "rails-uploads"
  s.version     = RailsUploads::VERSION
  s.authors     = ["Mattways"]
  s.email       = ["contact@mattways.com"]
  s.homepage    = "https://github.com/mattways/rails-uploads"
  s.summary     = "Toolkit for Rails uploads."
  s.description = "Adds models and migrations to deal with audio, image and video uploads."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2.8"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "debugger"  
end
