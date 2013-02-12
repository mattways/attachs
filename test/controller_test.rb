require 'test_helper'
 
class ControllerTest < ActionDispatch::IntegrationTest
  include ActionDispatch::TestProcess

  setup :create_image

  test "should generate preset" do
    
    puts @image.url
    
    ::File.delete @image.realpath(:small)
    path = ::File.join('', 'uploads', 'images', 'small', @image.filename)

    get path
    assert_redirected_to path

    realpath = Rails.root.join('public', 'uploads', 'images', 'small', @image.filename)
    assert ::File.exists?(realpath)
    @image.delete
  end

  protected

  def create_image
    @image = RailsUploads::Types::Image.new(fixture_file_upload(::File.join('', 'image.jpg'), 'image/jpeg'))
    @image.store
  end

end