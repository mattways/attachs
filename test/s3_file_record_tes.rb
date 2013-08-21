require 'test_helper'

class S3FileRecordTest < ActiveSupport::TestCase

  setup do
    load_s3
    @record = FileAttached.create(file: fixture_file_upload('/file.txt', 'text/plain'))
  end

  test "should maintain properties and delete correctly" do
    assert @record.file.exists?
    assert_equal 11, @record.file.size
    assert_equal '.txt', @record.file.extname

    uploads_url = @record.file.url
    @record.destroy
    assert_not_object_s3 uploads_url
    assert !@record.file.exists?
  end

end
