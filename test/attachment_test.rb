require 'test_helper'

class AttachmentTest < ActiveSupport::TestCase

  teardown do
    clean_storage
  end

  test 'attachment source' do
    original_medium = Medium.create(attach: file_upload)
    copied_medium = Medium.create(attach: original_medium.attach)
    %w(filename content_type size updated_at).each do |attr|
      assert_equal original_medium.attach.send(attr), copied_medium.attach.send(attr)
    end
  end

  test 'uri source' do
    medium = Medium.create(attach: URI('https://s3.amazonaws.com/attachs-test/file.txt'))
    file_path = Rails.root.join('public/storage/original/file.txt')
    assert File.exist?(file_path)
  end

end
