require 'test_helper'

class S3ImageUploadTest < ActiveSupport::TestCase

  setup do
    load_s3
    options = { presets: [:small, :big] }
    @image = Attachs::Types::Image.new(fixture_file_upload('/image.jpg', 'image/jpeg'), options)
    @image.store
  end

  test "should save/destory main image and thumbs" do
    original = @image.url
    big = @image.url(:big)
    small = @image.url(:small)

    assert_object_s3 original
    assert_object_s3 big
    assert_object_s3 small

    @image.delete
   
    assert_not_object_s3 original
    assert_not_object_s3 big
    assert_not_object_s3 small
  end

end
