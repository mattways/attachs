require 'test_helper'

class ActiveRecordTest < ActiveSupport::TestCase
  
  test "should save/update/destroy from the database and save/destroy the file" do

    # Save

    image_fixture_path = "#{ActiveSupport::TestCase.fixture_path}/image.jpg"
    record = Single.create(:file => Rack::Test::UploadedFile.new(image_fixture_path, 'image/jpeg'))

    image_filename = record.file.filename
    assert_equal image_filename, Single.first.file.filename

    image_upload_path = record.file.realpath
    assert File.exists?(image_upload_path)

    # Update

    doc_fixture_path = "#{ActiveSupport::TestCase.fixture_path}/doc.txt"
    record.update_attributes :file => Rack::Test::UploadedFile.new(doc_fixture_path, 'text/plain')

    doc_filename = record.file.filename 
    assert_not_equal image_filename, doc_filename
    assert_equal doc_filename, Single.first.file.filename
    
    doc_upload_path = record.file.realpath
    assert !File.exists?(image_upload_path)
    assert File.exists?(doc_upload_path)

    # Destroy

    record.destroy
    assert !Single.first
    assert !File.exists?(doc_upload_path)

  end

end
