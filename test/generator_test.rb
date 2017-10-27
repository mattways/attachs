require 'test_helper'
require 'rails/generators'
require 'generators/attachs/install/install_generator'

class GeneratorTest < Rails::Generators::TestCase
  destination Rails.root.join('tmp')

  teardown do
    FileUtils.rm_rf Dir.glob("#{destination_root}/*")
  end

  test 'install' do
    self.class.tests Attachs::Generators::InstallGenerator
    run_generator
    assert_file 'config/initializers/attachs.rb'
    assert_migration 'db/migrate/create_attachments.rb'
  end

end
