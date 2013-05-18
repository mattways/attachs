require 'test_helper'

class LocalImagePresetsTest < ActiveSupport::TestCase

  setup do
    @record = ImageUpload.create(:image => fixture_file_upload('/image.jpg', 'image/jpeg'))
  end

  test "should save/destory main image and thumbs" do
    original = Rails.root.join('tmp', 'uploads', 'images', 'original', @record.image.filename)
    big = Rails.root.join('tmp', 'uploads', 'images', 'big', @record.image.filename)
    small = Rails.root.join('tmp', 'uploads', 'images', 'small', @record.image.filename)

    assert ::File.exists?(original)
    assert ::File.exists?(big)
    assert ::File.exists?(small)
    
    @record.destroy
   
    assert !::File.exists?(original)
    assert !::File.exists?(big)
    assert !::File.exists?(small)
  end

end
