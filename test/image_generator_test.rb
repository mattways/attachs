require 'test_helper'
require 'rails/generators'
require 'generators/image_generator'

class ImageGeneratorTest < Rails::Generators::TestCase
  
  tests ImageGenerator
  destination File.expand_path('../tmp', File.dirname(__FILE__))
  setup :clean
  
  def clean
    FileUtils.rm_rf(self.destination_root)
  end
  
  test 'existence' do
    run_generator
    assert_file 'app/models/image.rb'
    assert_migration 'db/migrate/create_images.rb'  
    assert_directory 'public/uploads/images'
  end
  
end
