require 'test_helper'

class S3RecordsTest < ActiveSupport::TestCase

  setup do
    load_s3
  end
  
  test "should save/update/destroy from the database and save/destroy the file" do
    record = FileAttached.create(file: fixture_file_upload('/image.jpg', 'image/jpeg'))
    image_filename = record.file.filename
    image_url = record.file.url
    assert_object_s3 image_url

    record.update_attributes file: fixture_file_upload('/file.txt', 'text/plain')
    file_filename = record.file.filename 
    assert_not_equal image_filename, file_filename
    file_url = record.file.url
    assert_not_object_s3 image_url
    assert_object_s3 file_url

    record.destroy
    assert_not_object_s3 file_url
  end

  test "should take default file/image and shouldn't store/delete it" do
    record = FileAttached.create
    file_filename = 'file.txt'
    assert_equal ::File.join('uploads', 'files', file_filename), record.file.path
    file_url = record.file.url
    assert_object_s3 file_url

    record.destroy
    assert record.file.exists?
    assert_object_s3 file_url
  
    record = ImageAttached.create
    image_filename = 'image.jpg'
    assert_equal ::File.join('uploads', 'images', 'original', image_filename), record.image.path
    image_original_url = record.image.url
    assert_object_s3 image_original_url
    assert_equal ::File.join('uploads', 'images', 'small', image_filename), record.image.path(:small)
    image_small_url = record.image.url(:small)
    assert_object_s3 image_small_url
    assert_equal ::File.join('uploads', 'images', 'big', image_filename), record.image.path(:big)
    image_big_url = record.image.url(:big)
    assert_object_s3 image_big_url

    record.destroy
    assert record.image.exists?
    assert_object_s3 image_original_url
    assert_object_s3 image_small_url
    assert_object_s3 image_big_url
  end

end
