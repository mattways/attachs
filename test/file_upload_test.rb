require 'test_helper'

class FileUploadTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess

  setup :create_file

  test "methods should work properly" do
    
    # Basic tests
    
    assert @file.exists?
    assert_equal 58841, @file.size
    assert_equal '.jpg', @file.extname
    assert_equal ::File.join('', 'uploads', @file.filename), @file.path

    # Delete test
    
    @file.delete
    assert @file.exists?

    # Store and delete tests
    
    @file.store
    uploads_path = Rails.root.join('public', 'uploads', @file.filename)
    assert ::File.exists?(uploads_path)
    assert_equal uploads_path, @file.realpath
    
    @file.delete
    assert !::File.exists?(uploads_path)
    assert !@file.exists?
  
  end

  protected

  def create_file
    @file = RailsUploads::Types::File.new(fixture_file_upload('/image.jpg', 'image/jpeg'))
  end

end
