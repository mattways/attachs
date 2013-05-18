require 'test_helper'
 
class LocalGenerateTest < ActionDispatch::IntegrationTest

  setup do
    @image = RailsUploads::Types::Image.new(fixture_file_upload('/image.jpg', 'image/jpeg'))
    @image.store
  end

  teardown do
    @image.delete
  end

  test "should generate preset" do
    realpath = Rails.root.join('tmp', 'uploads', 'images', 'small', @image.filename)
    ::File.delete realpath

    path = ::File.join('', 'uploads', 'images', 'small', @image.filename)
    get path
    assert_redirected_to path

    assert ::File.exists?(realpath)
  end

end
