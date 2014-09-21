require 'test_helper'

class LocalStorageTest < ActiveSupport::TestCase

  test 'file url' do
    record = model.create(attach: file_upload)
    assert_equal file_url, record.attach.url
  end

  test 'image url' do
    record = model.create(attach: image_upload)
    assert_equal image_url, record.attach.url
    assert_equal image_url(:small), record.attach.url(:small)
  end

  test 'crud' do
    record = model.create(attach: file_upload)
    assert File.exist?(file_path)
    record.update_attributes! attach: image_upload
    assert !File.exist?(file_path)
    assert File.exist?(image_path)
    assert File.exist?(image_path(:small))
    record.destroy
    assert !File.exist?(image_path)
    assert !File.exist?(image_path(:small))
  end

  test 'detroy attr' do
    record = model.create(attach: file_upload, destroy_attach: true)
    assert File.exist?(file_path)
    record.update_attributes! destroy_attach: true
    assert !File.exist?(file_path)
  end

  private

  def month
    Time.zone.now.month
  end

  def model
    Class.new(User) do
      has_attached_file :attach, storage: 'local', path: '/storage/:type/:size/:style/:month/:basename.:extension', styles: [:small]
    end
  end

  def file_url(style=:original)
    "/storage/text/11/#{style}/#{month}/file.txt"
  end

  def image_url(style=:original)
    "/storage/image/5461/#{style}/#{month}/180x150.gif"
  end

  def file_path(style=:original)
    Rails.root.join("public/storage/text/11/#{style}/#{month}/file.txt")
  end

  def image_path(style=:original)
    Rails.root.join("public/storage/image/5461/#{style}/#{month}/180x150.gif")
  end

end
