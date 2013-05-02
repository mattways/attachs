require 'test_helper'

class RecordsTest < ActiveSupport::TestCase
  
  test "should save/update/destroy from the database and save/destroy the file" do

    # Save

    image_fixture_path = ::File.join(ActiveSupport::TestCase.fixture_path, 'image.jpg')
    record = FileUpload.create(:file => Rack::Test::UploadedFile.new(image_fixture_path, 'image/jpeg'))

    image_filename = record.file.filename
    assert_equal image_filename, FileUpload.first.file.filename

    image_upload_path = record.file.realpath
    assert ::File.exists?(image_upload_path)

    # Update

    doc_fixture_path = ::File.join(ActiveSupport::TestCase.fixture_path, 'file.txt')
    record.update_attributes :file => Rack::Test::UploadedFile.new(doc_fixture_path, 'text/plain')

    doc_filename = record.file.filename 
    assert_not_equal image_filename, doc_filename
    assert_equal doc_filename, FileUpload.first.file.filename
    
    doc_upload_path = record.file.realpath
    assert !::File.exists?(image_upload_path)
    assert ::File.exists?(doc_upload_path)

    # Destroy

    record.destroy
    assert !FileUpload.first
    assert !::File.exists?(doc_upload_path)

  end

  test "should take default file/image and shouldn't store/delete it" do

    # File

    record = FileUpload.create
    assert_equal ::File.join('', 'uploads', 'files', 'default.txt'), record.file.path
  
    # Image

    record = ImageUpload.create
    assert_equal ::File.join('', 'uploads', 'images', 'original', 'default.jpg'), record.image.path
    assert_equal ::File.join('', 'uploads', 'images', 'small', 'default.jpg'), record.image.path(:small)
    assert_equal ::File.join('', 'uploads', 'images', 'big', 'default.jpg'), record.image.path(:big)

  end

end
