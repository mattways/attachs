# Configure Rails Environment
ENV['RAILS_ENV'] = 'test'

require File.expand_path('../dummy/config/environment.rb',  __FILE__)
require 'rails/test_help'

Rails.backtrace_cleaner.remove_silencers!

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

# Load fixtures from the engine
if ActiveSupport::TestCase.method_defined?(:fixture_path=)
  ActiveSupport::TestCase.fixture_path = File.expand_path('../fixtures', __FILE__)
end

# Load database
config = YAML::load(File.read(File.expand_path('../dummy/config/database.yml', __FILE__)))
config['test']['adapter'] = 'jdbcsqlite3' if RUBY_PLATFORM == 'java'
ActiveRecord::Base.establish_connection(config['test'])
load(File.expand_path('../dummy/db/schema.rb', __FILE__))

# Addons
class ActiveSupport::TestCase
  include ActionDispatch::TestProcess

  def load_s3
    require 'aws-sdk' unless defined?(AWS)
    @storage_type = Rails.application.config.attachs.storage
    Rails.application.config.attachs.storage = :s3
    Attachs::Storages::S3.config = YAML.load_file(Rails.root.join('config', 's3.yml')) if Attachs::Storages::S3.config.blank?
    self.class.teardown { Rails.application.config.attachs.storage = @storage_type }
  end

  def fixture_file_upload_s3(fixture, type, path, default=false)
    upload = fixture_file_upload(fixture, type)
    storage = Attachs::Storages::S3.new(default, false)
    storage.store upload, path
  end

  def assert_object_s3(url)
    assert_equal '200', Net::HTTP.get_response(url).code
  end

  def assert_not_object_s3(url)
    assert_equal '403', Net::HTTP.get_response(url).code
  end
end

