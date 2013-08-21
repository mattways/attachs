require 'test_helper'

class LocalFileRecordTest < ActiveSupport::TestCase

  setup do
    @record = FileAttached.create(file: fixture_file_upload('/file.txt', 'text/plain'))
  end

  test "should maintain properties and delete correctly" do
    assert @record.file.exists?
    assert_equal 11, @record.file.size
    assert_equal '.txt', @record.file.extname

    uploads_path = Rails.root.join('tmp', 'uploads', 'files', @record.file.filename)
    @record.destroy
    assert !::File.exists?(uploads_path)
    assert !@record.file.exists?
  end

end
