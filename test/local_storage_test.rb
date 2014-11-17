require 'test_helper'

class LocalStorageTest < ActiveSupport::TestCase

  test 'file url' do
    medium = Medium.create(local_attach: file_upload)
    assert_equal file_url(:original, medium.local_attach), medium.local_attach.url
  end

  test 'image url' do
    medium = Medium.create(local_attach: image_upload)
    assert_equal image_url(:original, medium.local_attach), medium.local_attach.url
    assert_equal image_url(:small, medium.local_attach), medium.local_attach.url(:small)
  end

  test 'crud' do
    medium = Medium.create(local_attach: file_upload)
    assert File.exist?(file_path)
    medium.update_attributes! local_attach: image_upload
    assert !File.exist?(file_path)
    assert File.exist?(image_path)
    assert File.exist?(image_path(:small))
    medium.destroy
    assert !File.exist?(image_path)
    assert !File.exist?(image_path(:small))
  end

  test 'detroy attr' do
    medium = Medium.create(local_attach: file_upload, destroy_attach: true)
    assert File.exist?(file_path)
    medium.update_attributes! destroy_local_attach: true
    assert !File.exist?(file_path)
  end

  private

  def month
    Time.zone.now.month
  end

  def file_url(style=:original, attachment)
    "/storage/text/11/#{style}/#{month}/file.txt?#{attachment.updated_at.to_i}"
  end

  def image_url(style=:original, attachment)
    "/storage/image/5461/#{style}/#{month}/180x150.gif?#{attachment.updated_at.to_i}"
  end

  def file_path(style=:original)
    Rails.root.join("public/storage/text/11/#{style}/#{month}/file.txt")
  end

  def image_path(style=:original)
    Rails.root.join("public/storage/image/5461/#{style}/#{month}/180x150.gif")
  end

end
