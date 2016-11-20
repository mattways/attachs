$:.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'attachs/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'attachs'
  s.version     = Attachs::VERSION
  s.authors     = ['mmontossi']
  s.email       = ['mmontossi@gmail.com']
  s.homepage    = 'https://github.com/mmontossi/attachs'
  s.summary     = 'File attachments for rails.'
  s.description = 'Json based attachments for records in rails.'
  s.license     = 'MIT'

  s.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']
  s.test_files = Dir['test/**/*']

  s.requirements << 'GraphicsMagick'

  s.required_ruby_version = '>= 2.0.0'

  s.add_dependency 'rails', ['>= 4.2.0', '< 4.3.0']
  s.add_dependency 'aws-sdk', '~> 2.0'

  s.add_development_dependency 'pg', '~> 0.18'
  s.add_development_dependency 'mocha', '~> 1.1'
end
