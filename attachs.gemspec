$:.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'attachs/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'attachs'
  s.version     = Attachs::VERSION
  s.authors     = ['mmontossi']
  s.email       = ['hi@museways.com']
  s.homepage    = 'https://github.com/museways/attachs'
  s.summary     = 'Uploads for rails'
  s.description = 'Async and seo friendly uploads for rails.'
  s.license     = 'MIT'

  s.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']

  s.requirements << 'GraphicsMagick'

  s.add_dependency 'rails', '~> 5.1'
  s.add_dependency 'tuning', '~> 5.1'
  s.add_dependency 'aws-sdk-s3', '~> 1.5'
  s.add_dependency 'mime-types', '~> 3.1'

  s.add_development_dependency 'pg', '~> 0.21'
  s.add_development_dependency 'mocha', '~> 1.2'
  s.add_development_dependency 'makers', '~> 5.1'
end
