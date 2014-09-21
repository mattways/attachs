require 'test_helper'

class S3StorageTest < ActiveSupport::TestCase

  test 'file url' do
    record = model.create(attach: file_upload)
    assert_equal file_url, record.attach.url
    assert_equal file_url(ssl: true), record.attach.url(ssl: true)
  end

  test 'image url' do
    record = model.create(attach: image_upload)
    assert_equal image_url, record.attach.url
    assert_equal image_url(ssl: true), record.attach.url(ssl: true)
    assert_equal image_url(:small), record.attach.url(:small)
    assert_equal image_url(:small, ssl: true), record.attach.url(:small, ssl: true)
  end

  test 'storage' do
    record = model.create(attach: file_upload)
    assert_url file_url
    record.update_attributes! attach: image_upload
    assert_not_url file_url
    assert_url image_url
    assert_url image_url(:small)
    record.destroy
    assert_not_url image_url
    assert_not_url image_url(:small)
  end

  test 'detroy attr' do
    record = model.create(attach: file_upload, destroy_attach: true)
    assert_url file_url
    record.update_attributes! destroy_attach: true
    assert_not_url file_url
  end

  private

  def month
    Time.zone.now.month
  end

  def model
    Class.new(User) do
      has_attached_file :attach, storage: 's3', path: '/storage/:type/:size/:style/:month/:basename.:extension', styles: [:small]
    end
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
