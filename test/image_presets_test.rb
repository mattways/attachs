require 'test_helper'

class PresetsTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess

  setup :create_image

  test "should save/destory main image and thumbs" do

    #assert_equal 58841, @record.image.size
    #assert_equal 89314, @record.image.size(:big)
    #assert_equal 12057, @record.image.size(:small)
    
    original = @record.image.realpath
    big = @record.image.realpath(:big)
    small = @record.image.realpath(:small)
    
    @record.destroy
   
    assert !File.exists?(original)
    assert !File.exists?(big)
    assert !File.exists?(small)

  end

  protected

  def create_image
    @record = ImageUpload.create :image => fixture_file_upload('/image.jpg', 'image/jpeg')
  end

end
