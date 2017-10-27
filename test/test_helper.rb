require File.expand_path('../../test/dummy/config/environment.rb', __FILE__)
ActiveRecord::Migrator.migrations_paths = [File.expand_path('../../test/dummy/db/migrate', __FILE__)]
ActiveRecord::Migrator.migrations_paths << File.expand_path('../../db/migrate', __FILE__)
require 'rails/test_help'
require 'mocha/mini_test'

# Filter out Minitest backtrace while allowing backtrace from other libraries
# to be shown.
Minitest.backtrace_filter = Minitest::BacktraceFilter.new

# Include handy helplers.
class ActiveSupport::TestCase

  private

  def assert_raises_message(message, &block)
    begin
      block.call
    rescue => e
      assert_equal message, e.message
    else
      raise "Expected to raise #{message} but none raised"
    end
  end

  def assert_path(path)
    response = fetch(path)
    assert_equal '200', response.code
  end

  def assert_not_path(path)
    response = fetch(path)
    assert_equal '403', response.code
  end

  def url(path)
    "https://attachs-test.s3.amazonaws.com/#{path}"
  end

  def fetch(path)
    url = "https://s3.amazonaws.com/#{configuration.bucket}/#{path}"
    Net::HTTP.get_response URI.parse(url)
  end

  def pdf_attachment(size=nil)
    Attachs::Attachment.new pdf_attributes(size)
  end

  def image_attachment(size=nil)
    Attachs::Attachment.new image_attributes(size)
  end

  def pdf_file
    File.new pdf_path
  end

  def image_file
    File.new image_path
  end

  def pdf_attributes(size=nil)
    { content_type: 'application/pdf', size: size }
  end

  def image_attributes(size=nil)
    { content_type: 'image/jpeg', size: size }
  end

  def tmp_path
    Rails.root.join 'tmp'
  end

  def pdf_path
    File.join fixture_path, 'file.pdf'
  end

  def image_path
    File.join fixture_path, 'image.jpg'
  end

  def clear_tmp
    FileUtils.rm_rf Dir.glob("#{tmp_path}/*")
  end

  def configuration
    Attachs.configuration
  end

  def console
    Attachs::Console
  end

  def storage
    Attachs.storage
  end

end
