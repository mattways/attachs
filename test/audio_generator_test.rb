require 'test_helper'
require 'rails/generators'
require 'generators/audio_generator'

class AudioGeneratorTest < Rails::Generators::TestCase
  
  tests AudioGenerator
  destination File.expand_path('../tmp', File.dirname(__FILE__))
  setup :clean
  
  def clean
    FileUtils.rm_rf(self.destination_root)
  end
  
  test 'existence' do
    run_generator
    assert_file 'app/models/audio.rb'
    assert_migration 'db/migrate/create_audios.rb'    
    assert_directory 'public/uploads/audios'    
  end
  
end
