require 'test_helper'

class LocalRecordsTest < ActiveSupport::TestCase
  
  test "should save/update/destroy from the database and save/destroy the file" do
    record = FileUpload.create(:file => fixture_file_upload('/image.jpg', 'image/jpeg'))
    image_filename = record.file.filename
    image_path = Rails.root.join('tmp', 'uploads', 'files', image_filename)
    assert ::File.exists?(image_path)

    record.update_attributes :file => fixture_file_upload('/file.txt', 'text/plain')
    file_filename = record.file.filename 
    assert_not_equal image_filename, file_filename
    file_path = Rails.root.join('tmp', 'uploads', 'files', file_filename)
    assert !::File.exists?(image_path)
    assert ::File.exists?(file_path)

    record.destroy
    assert !::File.exists?(file_path)
  end

  test "should take default file/image and shouldn't store/delete it" do
    record = FileUpload.create
    file_filename = 'file.txt'
    assert_equal ::File.join('uploads', 'files', file_filename), record.file.path
    file_realpath = Rails.root.join('public', 'uploads', 'files', file_filename)
    assert ::File.exists?(file_realpath)

    record.destroy
    assert record.file.exists?
    assert ::File.exists?(file_realpath)
  
    record = ImageUpload.create
    image_filename = 'image.jpg'
    assert_equal ::File.join('uploads', 'images', 'original', 'image.jpg'), record.image.path
    image_original_realpath = Rails.root.join('public', 'uploads', 'images', 'original', image_filename)
    assert ::File.exists?(image_original_realpath)
    assert_equal ::File.join('uploads', 'images', 'small', 'image.jpg'), record.image.path(:small)
    image_small_realpath = Rails.root.join('public', 'uploads', 'images', 'small', image_filename)
    assert ::File.exists?(image_small_realpath)
    assert_equal ::File.join('uploads', 'images', 'big', 'image.jpg'), record.image.path(:big)
    image_big_realpath = Rails.root.join('public', 'uploads', 'images', 'big', image_filename)
    assert ::File.exists?(image_big_realpath)

    record.destroy
    assert record.image.exists?
    assert ::File.exists?(image_original_realpath)
    assert ::File.exists?(image_small_realpath)
    assert ::File.exists?(image_big_realpath)
  end

end
