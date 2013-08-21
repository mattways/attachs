require 'test_helper'

class S3ImageStringTest < ActiveSupport::TestCase

  setup do
    load_s3
    filename = 'image.jpg'
    fixture_file_upload_s3 "/#{filename}", 'image/jpeg', ::File.join('uploads', 'images', 'original', filename)
    fixture_file_upload_s3 "/#{filename}", 'image/jpeg', ::File.join('uploads', 'images', 'big', filename)
    fixture_file_upload_s3 "/#{filename}", 'image/jpeg', ::File.join('uploads', 'images', 'small', filename)
    options = { presets: [:small, :big] }
    @image = Attachs::Types::Image.new(filename, options)
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
