require 'test_helper'
require 'rails/generators'
require 'generators/video_generator'

class VideoGeneratorTest < Rails::Generators::TestCase
  
  tests VideoGenerator
  destination File.expand_path('../tmp', File.dirname(__FILE__))
  setup :clean
  
  def clean
    FileUtils.rm_rf(self.destination_root)
  end
  
  test 'existence' do
    run_generator
    assert_file 'app/models/video.rb'
    assert_migration 'db/migrate/create_videos.rb'   
    assert_directory 'public/uploads/videos'     
  end
  
end
