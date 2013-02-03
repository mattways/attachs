require 'test_helper'

class ValidatorsTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess

  setup :create_record

  test "should check if file is present" do

    assert !@record.valid?
    assert_equal [I18n.t('errors.messages.attachment_presence')], @record.errors[:file_presence]

    @record.image_presence = fixture_file_upload(::File.join('', 'image.jpg'), 'image/jpeg')
    assert !@record.valid?
    assert_equal [], @record.errors[:image_presence]

  end

  test "should check the file content type" do

    @record.image_content_type = fixture_file_upload(::File.join('', 'file.txt'), 'text/plain')
    assert !@record.valid?
    assert_equal [I18n.t('errors.messages.attachment_content_type', :types => 'jpg')], @record.errors[:image_content_type]

    @record.file_content_type = fixture_file_upload(::File.join('', 'image.jpg'), 'image/jpeg')
    assert !@record.valid?
    assert_equal [I18n.t('errors.messages.attachment_content_type', :types => 'txt')], @record.errors[:file_content_type]

  end

  test "should check the file size" do

    @record.file_size = fixture_file_upload(::File.join('', 'file_big.txt'), 'text/plain')
    assert !@record.valid?
    assert_equal [I18n.t('errors.messages.attachment_size_less_than', :limit => 15.kilobytes)], @record.errors[:file_size]

    @record.file_size = fixture_file_upload(::File.join('', 'file_empty.txt'), 'text/plain')
    assert !@record.valid?
    assert_equal [I18n.t('errors.messages.attachment_size_greater_than', :limit => 10.bytes)], @record.errors[:file_size]

    @record.file_size = fixture_file_upload(::File.join('', 'file.txt'), 'text/plain')
    assert !@record.valid?
    assert_equal [], @record.errors[:file_size]

    @record.image_size = fixture_file_upload(::File.join('', 'image_big.jpg'), 'image/jpeg')
    assert !@record.valid?
    assert_equal [I18n.t('errors.messages.attachment_size_in', :begin => 2.kilobytes, :end => 60.kilobytes)], @record.errors[:image_size]

    @record.image_size = fixture_file_upload(::File.join('', 'image_empty.jpg'), 'image/jpeg')
    assert !@record.valid?
    assert_equal [I18n.t('errors.messages.attachment_size_in', :begin => 2.kilobytes, :end => 60.kilobytes)], @record.errors[:image_size]

    @record.image_size = fixture_file_upload(::File.join('', 'image.jpg'), 'image/jpeg')
    assert !@record.valid?
    assert_equal [], @record.errors[:image_size]

  end

  test "should check all the validations together" do

    @record.file_all = fixture_file_upload(::File.join('', 'file.txt'), 'text/plain')
    assert !@record.valid?
    assert_equal [], @record.errors[:file_all]

    @record.image_all = fixture_file_upload(::File.join('', 'image.jpg'), 'image/jpeg')
    assert !@record.valid?
    assert_equal [], @record.errors[:image_all]

    assert !@record.valid?
    assert_equal [], @record.errors[:file_default]

    assert !@record.valid?
    assert_equal [], @record.errors[:image_default]

  end

  protected

  def create_record
    @record = ValidationUpload.new
  end

end 
