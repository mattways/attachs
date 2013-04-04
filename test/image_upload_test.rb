require 'test_helper'

class ImageUploadTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess

  setup :create_image

  test 'should save/destory main image and thumbs' do

    #assert_equal 58841, @image.size
    #assert_equal 89314, @image.size(:big)
    #assert_equal 12057, @image.size(:small)
    
    original = @image.realpath
    big = @image.realpath(:big)
    small = @image.realpath(:small)
    
    @image.delete
    
    assert !File.exists?(original)
    assert !File.exists?(big)
    assert !File.exists?(small)

  end

  protected

  def create_image
    @options = { :presets => [:small, :big] }
    @image = Rails::Uploads::Types::Image.new(fixture_file_upload(::File.join('', 'image.jpg'), 'image/jpeg'), @options)
    @image.store
  end

end
