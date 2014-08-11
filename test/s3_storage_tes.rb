require 'test_helper'

class S3StorageTest < ActiveSupport::TestCase

  test "url" do
    assert_match %r{http://attachs-test.s3.amazonaws.com/\d+-file.txt}, file_attachment.url
    assert_match %r{https://attachs-test.s3.amazonaws.com/\d+-file.txt}, file_attachment.url(ssl: true)
    assert_equal "http://attachs-test.s3.amazonaws.com/storage/image/5461/original/#{month}/180x150.gif", image_attachment.url
    assert_equal "https://attachs-test.s3.amazonaws.com/storage/image/5461/original/#{month}/180x150.gif", image_attachment.url(ssl: true)
    assert_equal "http://attachs-test.s3.amazonaws.com/storage/image/5461/small/#{month}/180x150.gif", image_attachment.url(:small)
    assert_equal "https://attachs-test.s3.amazonaws.com/storage/image/5461/small/#{month}/180x150.gif", image_attachment.url(:small, ssl: true)
  end

  test "storage" do
    file_object = file_attachment.send(:type).send(:storage).send(:object)
    file_attachment.process
    assert file_object.exists?
    file_attachment.destroy
    assert !file_object.exists?

    original_image_object = image_attachment.send(:type).send(:storage).send(:object)
    small_image_object = image_attachment.send(:type).send(:storage).send(:object)
    image_attachment.process
    assert original_image_object.exists?
    assert small_image_object.exists?
    image_attachment.destroy
    assert !original_image_object.exists?
    assert !small_image_object.exists?
  end

  private

  def month
    Time.zone.now.month
  end

  def file_attachment
    @file_attachment ||= begin
      options = { storage: 's3' }
      Attachs::Attachment.new(nil, nil, options, file_upload)
    end
  end

  def image_attachment
    @image_attachment ||= begin
      options = { storage: 's3', path: '/storage/:type/:size/:style/:month/:basename.:extension', styles: [:small] }
      Attachs::Attachment.new(nil, nil, options, image_upload)
    end
  end

end
