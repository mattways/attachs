require 'test_helper'

class LocalImageUploadTest < ActiveSupport::TestCase

  setup do
    options = { :presets => [:small, :big] }
    @image = RailsUploads::Types::Image.new(fixture_file_upload('/image.jpg', 'image/jpeg'), options)
    @image.store
  end

  test "should save/destory main image and thumbs" do
    original = Rails.root.join('tmp', 'uploads', 'images', 'original', @image.filename)
    big = Rails.root.join('tmp', 'uploads', 'images', 'big', @image.filename)
    small = Rails.root.join('tmp', 'uploads', 'images', 'small', @image.filename)

    assert ::File.exists?(original)
    assert ::File.exists?(big)
    assert ::File.exists?(small)
    
    @image.delete
    
    assert !::File.exists?(original)
    assert !::File.exists?(big)
    assert !::File.exists?(small)
  end

end
