require 'test_helper'
require 'rails/generators'
require 'generators/attachs/install_generator'
require 'generators/attachs/upload_generator'

class GeneratorsTest < Rails::Generators::TestCase
  destination File.expand_path('../tmp', File.dirname(__FILE__))

  teardown do
    FileUtils.rm_rf self.destination_root
  end

  test 'install' do
    self.class.tests Attachs::InstallGenerator
    run_generator
    assert_file 'config/initializers/attachs.rb'
  end

  test 'upload' do
    self.class.tests Attachs::UploadGenerator
    run_generator
    assert_file 'app/models/upload.rb'
    assert_migration 'db/migrate/create_uploads.rb'
  end

end
