require 'test_helper'

class RecordTest < ActiveSupport::TestCase

  test "crud" do
    user.save!
    assert File.exist?(file_path)
    user.update_attributes! avatar: image_upload
    assert File.exist?(image_path)
    assert !File.exist?(file_path)
    user.destroy
    assert !File.exist?(file_path)
    assert !File.exist?(image_path)
  end

  private

  def file_path
    Rails.root.join('public', 'original', 'file.txt')
  end

  def image_path
    Rails.root.join('public', 'original', '180x150.gif')
  end

  def user
    @user ||= User.new(avatar: file_upload)
  end

end
