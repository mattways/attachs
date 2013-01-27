require 'test_helper'

class ValidatorsTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess

  setup :create_record

  test "should check if file is present" do

    assert !@record.valid?
    assert_equal [I18n.t('errors.messages.attachment_presence')], @record.errors[:doc_presence]

    @record.image_presence = fixture_file_upload('/image.jpg', 'image/jpeg')
    assert !@record.valid?
    assert_equal [], @record.errors[:image_presence]

  end

  test "should check the file content type" do

    @record.image_content_type = fixture_file_upload('/doc.txt', 'text/plain')
    assert !@record.valid?
    assert_equal [I18n.t('errors.messages.attachment_content_type', :types => 'jpg')], @record.errors[:image_content_type]

    @record.doc_content_type = fixture_file_upload('/image.jpg', 'image/jpeg')
    assert !@record.valid?
    assert_equal [I18n.t('errors.messages.attachment_content_type', :types => 'txt')], @record.errors[:doc_content_type]

  end

  test "should check the file size" do

    @record.doc_size = fixture_file_upload('/doc_big.txt', 'text/plain')
    assert !@record.valid?
    assert_equal [I18n.t('errors.messages.attachment_size_less_than', :limit => 15.kilobytes)], @record.errors[:doc_size]

    @record.doc_size = fixture_file_upload('/doc_empty.txt', 'text/plain')
    assert !@record.valid?
    assert_equal [I18n.t('errors.messages.attachment_size_greater_than', :limit => 10.bytes)], @record.errors[:doc_size]

    @record.doc_size = fixture_file_upload('/doc.txt', 'text/plain')
    assert !@record.valid?
    assert_equal [], @record.errors[:doc_size]

    @record.image_size = fixture_file_upload('/image_big.jpg', 'image/jpeg')
    assert !@record.valid?
    assert_equal [I18n.t('errors.messages.attachment_size_in', :begin => 2.kilobytes, :end => 60.kilobytes)], @record.errors[:image_size]

    @record.image_size = fixture_file_upload('/image_empty.jpg', 'image/jpeg')
    assert !@record.valid?
    assert_equal [I18n.t('errors.messages.attachment_size_in', :begin => 2.kilobytes, :end => 60.kilobytes)], @record.errors[:image_size]

    @record.image_size = fixture_file_upload('/image.jpg', 'image/jpeg')
    assert !@record.valid?
    assert_equal [], @record.errors[:image_size]

  end

  test "should check all the validations together" do

    @record.doc_all = fixture_file_upload('/doc.txt', 'text/plain')
    assert !@record.valid?
    assert_equal [], @record.errors[:doc_all]

    @record.image_all = fixture_file_upload('/image.jpg', 'image/jpeg')
    assert !@record.valid?
    assert_equal [], @record.errors[:image_all]

  end

  protected

  def create_record
    @record = SingleValidations.new
  end

end 
