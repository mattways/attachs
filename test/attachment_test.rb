require 'test_helper'

class AttachmentTest < ActiveSupport::TestCase

  test "attribute" do
    assert_equal :file, file_attachment.attribute
  end

  test "filename" do
    assert_equal 'file.txt', file_attachment.filename
  end

  test "content_type" do
    assert_equal 'text/plain', file_attachment.content_type
  end

  test "size" do
    assert_equal 11, file_attachment.size
  end

  test "updated_at" do
    assert_equal Time.zone.now.to_date, file_attachment.updated_at.to_date
  end

  test "basename" do
    assert_equal 'file', file_attachment.basename
  end

  test "extension" do
    assert_equal 'txt', file_attachment.extension
  end

  test "styles" do
    assert_equal [:small, :medium, :big], file_attachment.styles
    assert_equal [:small, :medium, :big], image_attachment.styles
  end

  test "image?" do
    assert !file_attachment.image?
    assert image_attachment.image?
  end

  test "private?" do
    assert !file_attachment.private?
  end

  test "upload?" do
    assert file_attachment.upload?
  end

  private

  def file_attachment(options={})
    Attachs::Attachment.new(nil, :file, options, file_upload)
  end

  def image_attachment(options={})
    Attachs::Attachment.new(nil, :image, options.merge(styles: [:small]), image_upload)
  end

end
