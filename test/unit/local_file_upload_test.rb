require 'test_helper'

class LocalFileUploadTest < ActiveSupport::TestCase

  setup do
    @file = RailsUploads::Types::File.new(fixture_file_upload('/image.jpg', 'image/jpeg'))
  end

  test "file should exists and mantain properties" do
    assert @file.exists?
    assert_equal 58841, @file.size
    assert_equal '.jpg', @file.extname
  end

  test "should store/delete file correctly and accept cdn" do
    @file.store
    uploads_path = Rails.root.join('tmp', 'uploads', 'files', @file.filename)
    assert ::File.exists?(uploads_path)

    base_url = 'http://cdn.example.com'
    Rails.application.config.uploads.base_url = base_url
    assert_equal ::File.join(base_url, @file.path), @file.url
    Rails.application.config.uploads.base_url = ''

    @file.delete
    assert !::File.exists?(uploads_path)
    assert !@file.exists?
  end

end
