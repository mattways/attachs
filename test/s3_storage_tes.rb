require 'test_helper'

class S3StorageTest < ActiveSupport::TestCase

  test 'file url' do
    medium = Medium.create(s3_attach: file_upload)
    assert_equal file_url, medium.s3_attach.url
    assert_equal file_url(ssl: true), medium.s3_attach.url(ssl: true)
  end

  test 'image url' do
    medium = Medium.create(s3_attach: image_upload)
    assert_equal image_url, medium.s3_attach.url
    assert_equal image_url(ssl: true), medium.s3_attach.url(ssl: true)
    assert_equal image_url(:small), medium.s3_attach.url(:small)
    assert_equal image_url(:small, ssl: true), medium.s3_attach.url(:small, ssl: true)
  end

  test 'storage' do
    medium = Medium.create(s3_attach: file_upload)
    assert_url file_url
    medium.update_attributes! s3_attach: image_upload
    assert_not_url file_url
    assert_url image_url
    assert_url image_url(:small)
    medium.destroy
    assert_not_url image_url
    assert_not_url image_url(:small)
  end

  test 'detroy attr' do
    medium = Medium.create(s3_attach: file_upload, destroy_s3_attach: true)
    assert_url file_url
    medium.update_attributes! destroy_s3_attach: true
    assert_not_url file_url
  end

  private

  def month
    Time.zone.now.month
  end

  def file_url(*args)
    options = args.extract_options!
    style = (args.first || :original)
    "http#{'s' if options[:ssl]}://attachs-test.s3.amazonaws.com/storage/text/11/#{style}/#{month}/file.txt"
  end

  def image_url(*args)
    options = args.extract_options!
    style = (args.first || :original)
    "http#{'s' if options[:ssl]}://attachs-test.s3.amazonaws.com/storage/image/5461/#{style}/#{month}/180x150.gif"
  end

end
