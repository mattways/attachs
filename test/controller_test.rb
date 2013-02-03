require 'test_helper'
 
class ControllerTest < ActionDispatch::IntegrationTest
  include ActionDispatch::TestProcess

  setup :create_image

  test "should generate preset" do
    Rails.application.config.uploads.presets[:other] = { :width => 300, :height => 300 }
    path = ::File.join('', 'uploads', 'images', 'other', @image.filename)

    get path
    assert_redirected_to path

    realpath = Rails.root.join('public', 'uploads', 'images', 'other', @image.filename)
    assert ::File.exists?(realpath)
    ::File.delete realpath
  end

  protected

  def create_image
    @image = RailsUploads::Types::Image.new(fixture_file_upload(::File.join('', 'image.jpg'), 'image/jpeg'))
    @image.store
  end

end
