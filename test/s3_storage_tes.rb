require 'test_helper'

class S3StorageTest < ActiveSupport::TestCase

  test 'file url' do
    medium = Medium.create(s3_attach: file_upload)
    assert_equal file_url(:original, medium, true, false), medium.s3_attach.url
    assert_equal file_url(:original, medium, false, false), medium.s3_attach.url(cachebuster: false)
    assert_equal file_url(:original, medium, true, true), medium.s3_attach.url(ssl: true)
    assert_equal file_url(:original, medium, false, true), medium.s3_attach.url(ssl: true, cachebuster: false)
  end

  test 'image url' do
    medium = Medium.create(s3_attach: image_upload)
    assert_equal image_url(:original, medium, true, false), medium.s3_attach.url
    assert_equal image_url(:original, medium, false, false), medium.s3_attach.url(cachebuster: false)
    assert_equal image_url(:original, medium, true, true), medium.s3_attach.url(ssl: true)
    assert_equal image_url(:original, medium, false, true), medium.s3_attach.url(ssl: true, cachebuster: false)
    assert_equal image_url(:small, medium, true, false), medium.s3_attach.url(:small)
    assert_equal image_url(:small, medium, false, false), medium.s3_attach.url(:small, cachebuster: false)
    assert_equal image_url(:small, medium, true, true), medium.s3_attach.url(:small, ssl: true)
    assert_equal image_url(:small, medium, false, true), medium.s3_attach.url(:small, ssl: true, cachebuster: false)
  end

  test 'storage' do
    medium = Medium.create(s3_attach: file_upload)
    assert_url file_url(:original, medium)
    medium.update_attributes! s3_attach: image_upload
    assert_not_url file_url(:original, medium)
    assert_url image_url(:original, medium)
    assert_url image_url(:small, medium)
    medium.destroy
    assert_not_url image_url(:original, medium)
    assert_not_url image_url(:small, medium)
  end

  test 'detroy attr' do
    medium = Medium.create(s3_attach: file_upload, destroy_s3_attach: true)
    assert_url file_url(:original, medium)
    medium.update_attributes! destroy_s3_attach: true
    assert_not_url file_url(:original, medium)
  end

  private

  def month
    Time.zone.now.month
  end

  def file_url(style, record, cachebuster=true, ssl=false)
    "http#{'s' if ssl}://attachs-test.s3.amazonaws.com/storage/text/11/#{style}/#{month}/file.txt".tap do |url|
      if cachebuster 
        url << "?#{record.s3_attach_updated_at.to_i}"
      end
    end
  end

  def image_url(style, record, cachebuster=true, ssl=false)
    "http#{'s' if ssl}://attachs-test.s3.amazonaws.com/storage/image/5461/#{style}/#{month}/180x150.gif".tap do |url|
      if cachebuster
        url << "?#{record.s3_attach_updated_at.to_i}"
      end
    end
  end

end
