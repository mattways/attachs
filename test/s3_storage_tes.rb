require 'test_helper'

class S3StorageTest < ActiveSupport::TestCase

  test 'file url' do
    medium = Medium.create(s3_attach: file_upload)
    assert_equal file_url(:original, medium, false), medium.s3_attach.url
    assert_equal file_url(:original, medium, true), medium.s3_attach.url(ssl: true)
  end

  test 'image url' do
    medium = Medium.create(s3_attach: image_upload)
    assert_equal image_url(:original, medium, false), medium.s3_attach.url
    assert_equal image_url(:original, medium, true), medium.s3_attach.url(ssl: true)
    assert_equal image_url(:small, medium, false), medium.s3_attach.url(:small)
    assert_equal image_url(:small, medium, true), medium.s3_attach.url(:small, ssl: true)
  end

  test 'storage' do
    medium = Medium.create(s3_attach: file_upload)
    assert_url file_url(:original, medium, false)
    medium.update_attributes! s3_attach: image_upload
    assert_not_url file_url(:original, medium, false)
    assert_url image_url(:original, medium, false)
    assert_url image_url(:small, medium, false)
    medium.destroy
    assert_not_url image_url(:original, medium, false)
    assert_not_url image_url(:small, medium, false)
  end

  test 'detroy attr' do
    medium = Medium.create(s3_attach: file_upload, destroy_s3_attach: true)
    assert_url file_url(:original, medium, false)
    medium.update_attributes! destroy_s3_attach: true
    assert_not_url file_url(:original, medium, false)
  end

  private

  def month
    Time.zone.now.month
  end

  def file_url(style, record, ssl)
    "http#{'s' if ssl}://attachs-test.s3.amazonaws.com/storage/text/11/#{style}/#{month}/file.txt?#{record.s3_attach_updated_at.to_i}"
  end

  def image_url(style, record, ssl)
    "http#{'s' if ssl}://attachs-test.s3.amazonaws.com/storage/image/5461/#{style}/#{month}/180x150.gif?#{record.s3_attach_updated_at.to_i}"
  end

end
