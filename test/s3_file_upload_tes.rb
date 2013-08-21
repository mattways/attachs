require 'test_helper'

class S3FileUploadTest < ActiveSupport::TestCase

  setup do
    load_s3 
    @file = Attachs::Types::File.new(fixture_file_upload('/image.jpg', 'image/jpeg'))
  end

  test "file should exists and mantain properties" do
    assert @file.exists?
    assert_equal 58841, @file.size
    assert_equal '.jpg', @file.extname
  end

  test "should store/delete file correctly and accept cdn" do
    @file.store
    uploads_url = @file.url
    assert_object_s3 uploads_url

    base_url = 'http://cdn.example.com'
    Rails.application.config.attachs.base_url = base_url
    assert_equal ::File.join(base_url, @file.path), @file.url
    Rails.application.config.attachs.base_url = ''

    @file.delete
    assert_not_object_s3 uploads_url
    assert !@file.exists?
  end

end
