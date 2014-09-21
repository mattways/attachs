require 'test_helper'

class AttachmentTest < ActiveSupport::TestCase

  test 'attachment source' do
    original_user = User.create(attach: file_upload)
    copied_user = User.create(attach: original_user.attach)
    %w(filename content_type size updated_at).each do |attr|
      assert_equal original_user.attach.send(attr), copied_user.attach.send(attr)
    end
  end

  test 'uri source' do
    user = User.create!(attach: URI('https://s3.amazonaws.com/attachs-test/file.txt'))
    file_path = Rails.root.join('public/original/file.txt')
    assert File.exist?(file_path)
  end

end
