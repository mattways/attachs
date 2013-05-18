require 'test_helper'

class S3FileStringTest < ActiveSupport::TestCase

  setup do
    load_s3
    filename = 'file.txt'
    fixture_file_upload_s3 "/#{filename}", 'text/plain', ::File.join('uploads', 'files', filename)
    @file = RailsUploads::Types::File.new(filename)
  end

  test "should maintain properties and delete correctly" do
    assert @file.exists?
    assert_equal 11, @file.size
    assert_equal '.txt', @file.extname
    assert_equal ::File.join('uploads', 'files', @file.filename), @file.path

    uploads_url = @file.url
    @file.delete
    assert_not_object_s3 uploads_url
    assert !@file.exists?
  end

end
