$:.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'rails_uploads/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'rails_uploads'
  s.version     = RailsUploads::VERSION
  s.authors     = ['Mattways']
  s.email       = ['contact@mattways.com']
  s.homepage    = 'https://github.com/mattways/rails_uploads'
  s.summary     = 'Toolkit for Rails Uploads.'
  s.description = 'Minimalistic toolkit to handle file and images uploads using ActiveRecord.'

  s.files = Dir["{app,config,db,lib}/**/*"] + ['MIT-LICENSE', 'Rakefile', 'README.rdoc']
  s.test_files = Dir['test/**/*']

  s.requirements << 'ImageMagick'

  s.add_dependency 'rails', '>= 3.2.8'
  s.add_dependency 'aws-sdk'

  if RUBY_PLATFORM == 'java'
    s.add_development_dependency 'activerecord-jdbcsqlite3-adapter'
    s.add_development_dependency 'jruby-openssl'
  else
    s.add_development_dependency 'sqlite3'
  end
end
