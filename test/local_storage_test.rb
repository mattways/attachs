require 'test_helper'

class LocalStorageTest < ActiveSupport::TestCase

  test "url" do
    assert_match %r{/\d+-file.txt}, file_attachment.url
    assert_equal "/storage/image/5461/original/#{month}/180x150.gif", image_attachment.url
    assert_equal "/storage/image/5461/small/#{month}/180x150.gif", image_attachment.url(:small)
  end

  test "storage" do
    file_realpath = file_attachment.send(:type).send(:storage).send(:realpath)
    file_attachment.process
    assert File.exist?(file_realpath)
    file_attachment.destroy
    assert !File.exist?(file_realpath)

    original_image_realpath = image_attachment.send(:type).send(:storage).send(:realpath)
    small_image_realpath = image_attachment.send(:type).send(:storage).send(:realpath)
    image_attachment.process
    assert File.exist?(original_image_realpath)
    assert File.exist?(small_image_realpath)
    image_attachment.destroy
    assert !File.exist?(original_image_realpath)
    assert !File.exist?(small_image_realpath)
  end

  private

  def month
    Time.zone.now.month
  end

  def file_attachment
    @file_attachment ||= begin
      options = { storage: 'local' }
      Attachs::Attachment.new(nil, nil, options, file_upload)
    end
  end

  def image_attachment
    @image_attachment ||= begin
      options = { storage: 'local', path: '/storage/:type/:size/:style/:month/:basename.:extension', styles: [:small] }
      Attachs::Attachment.new(nil, nil, options, image_upload)
    end
  end

end
