require 'test_helper'

class FileStringTest < ActiveSupport::TestCase

  setup :create_file

  test "methods should work properly" do

    # Basic tests

    assert @file.exists?
    assert_equal 11, @file.size
    assert_equal '.txt', @file.extname
    assert_equal ::File.join('', 'uploads', 'files', @file.filename), @file.path
    assert_equal Rails.root.join('tmp', 'uploads', 'files', @file.filename).to_s, @file.realpath

    # Delete tests

    uploads_path = Rails.root.join('tmp', 'uploads', 'files', @file.filename).to_s
    @file.delete
    assert !::File.exists?(uploads_path)
    assert !@file.exists?

  end

  protected

  def create_file
    FileUtils.mkdir_p Rails.root.join('tmp', 'uploads', 'files')
    filename = 'file.txt'
    FileUtils.cp ::File.join(ActiveSupport::TestCase.fixture_path, filename), Rails.root.join('tmp', 'uploads', 'files', filename)
    @file = RailsUploads::Types::File.new(filename)
  end

end
