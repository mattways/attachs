require 'test_helper'

class S3ImageRecordTest < ActiveSupport::TestCase

  setup do
    load_s3
    @record = ImageAttached.create(image: fixture_file_upload('/image.jpg', 'image/jpeg'))
  end

  test "should save/destory main image and thumbs" do
    original = @record.image.url
    big = @record.image.url(:big)
    small = @record.image.url(:small)

    assert_object_s3 original
    assert_object_s3 big
    assert_object_s3 small
    
    @record.destroy
   
    assert_not_object_s3 original
    assert_not_object_s3 big
    assert_not_object_s3 small
  end

end
