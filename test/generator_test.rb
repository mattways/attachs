require 'test_helper'
require 'rails/generators'
require 'generators/attachs/install/install_generator'
require 'generators/attachs/upload/upload_generator'

class GeneratorTest < Rails::Generators::TestCase
  destination Rails.root.join('tmp')

  teardown do
    FileUtils.rm_rf destination_root
  end

  test 'install' do
    self.class.tests Attachs::Generators::InstallGenerator
    run_generator
    assert_file 'config/initializers/attachs.rb'
  end

  test 'upload' do
    self.class.tests Attachs::Generators::UploadGenerator
    run_generator
    assert_file 'app/models/upload.rb'
    assert_migration 'db/migrate/create_uploads.rb'
  end

end
