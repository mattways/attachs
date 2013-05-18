require 'test_helper'

class S3ValidatorsTest < ActiveSupport::TestCase

  setup do
    load_s3
    @record = ValidationUpload.new
  end

  test "should check if file is present" do
    assert !@record.valid?
    assert_equal [I18n.t('errors.messages.attachment_presence')], @record.errors[:file_presence]

    @record.image_presence = fixture_file_upload('/image.jpg', 'image/jpeg')
    assert !@record.valid?
    assert_equal [], @record.errors[:image_presence]
  end

  test "should check the file content type" do
    @record.image_content_type = fixture_file_upload('/file.txt', 'text/plain')
    assert !@record.valid?
    assert_equal [I18n.t('errors.messages.attachment_content_type', :types => 'jpg')], @record.errors[:image_content_type]

    @record.file_content_type = fixture_file_upload('/image.jpg', 'image/jpeg')
    assert !@record.valid?
    assert_equal [I18n.t('errors.messages.attachment_content_type', :types => 'txt')], @record.errors[:file_content_type]
  end

  test "should check the file size" do
    @record.file_size = fixture_file_upload('/file_big.txt', 'text/plain')
    assert !@record.valid?
    assert_equal [I18n.t('errors.messages.attachment_size_less_than', :less_than => 15.kilobytes)], @record.errors[:file_size]

    @record.file_size = fixture_file_upload('/file_empty.txt', 'text/plain')
    assert !@record.valid?
    assert_equal [I18n.t('errors.messages.attachment_size_greater_than', :greater_than => 10.bytes)], @record.errors[:file_size]

    @record.file_size = fixture_file_upload('/file.txt', 'text/plain')
    assert !@record.valid?
    assert_equal [], @record.errors[:file_size]

    @record.image_size = fixture_file_upload('/image_big.jpg', 'image/jpeg')
    assert !@record.valid?
    assert_equal [I18n.t('errors.messages.attachment_size_in', :greater_than => 2.kilobytes, :less_than => 60.kilobytes)], @record.errors[:image_size]

    @record.image_size = fixture_file_upload('/image_empty.jpg', 'image/jpeg')
    assert !@record.valid?
    assert_equal [I18n.t('errors.messages.attachment_size_in', :greater_than => 2.kilobytes, :less_than => 60.kilobytes)], @record.errors[:image_size]

    @record.image_size = fixture_file_upload('/image.jpg', 'image/jpeg')
    assert !@record.valid?
    assert_equal [], @record.errors[:image_size]
  end

  test "should check all the validations together" do
    @record.file_all = fixture_file_upload('/file.txt', 'text/plain')
    assert !@record.valid?
    assert_equal [], @record.errors[:file_all]

    @record.image_all = fixture_file_upload('/image.jpg', 'image/jpeg')
    assert !@record.valid?
    assert_equal [], @record.errors[:image_all]

    assert !@record.valid?
    assert_equal [], @record.errors[:file_default]

    assert !@record.valid?
    assert_equal [], @record.errors[:image_default]
  end

end 
