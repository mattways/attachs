require 'test_helper'

class LocalFileStringTest < ActiveSupport::TestCase

  setup do
    FileUtils.mkdir_p Rails.root.join('tmp', 'uploads', 'files')
    filename = 'file.txt'
    FileUtils.cp fixture_file_upload("/#{filename}", 'text/plain'), Rails.root.join('tmp', 'uploads', 'files', filename)
    @file = RailsUploads::Types::File.new(filename)
  end

  test "should maintain properties and delete correctly" do
    assert @file.exists?
    assert_equal 11, @file.size
    assert_equal '.txt', @file.extname

    uploads_path = Rails.root.join('tmp', 'uploads', 'files', @file.filename)
    @file.delete
    assert !::File.exists?(uploads_path)
    assert !@file.exists?
  end

end
