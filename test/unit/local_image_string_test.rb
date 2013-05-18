require 'test_helper'

class LocalImageStringTest < ActiveSupport::TestCase

  setup do
    FileUtils.mkdir_p Rails.root.join('tmp', 'uploads', 'images', 'original')
    FileUtils.mkdir_p Rails.root.join('tmp', 'uploads', 'images', 'big')
    FileUtils.mkdir_p Rails.root.join('tmp', 'uploads', 'images', 'small')
    filename = 'image.jpg'
    fixture = fixture_file_upload("/#{filename}", 'image/jpeg') 
    FileUtils.cp fixture, Rails.root.join('tmp', 'uploads', 'images', 'original', filename)
    FileUtils.cp fixture, Rails.root.join('tmp', 'uploads', 'images', 'big', filename)
    FileUtils.cp fixture, Rails.root.join('tmp', 'uploads', 'images', 'small', filename)
    options = { :presets => [:small, :big] }
    @image = RailsUploads::Types::Image.new(filename, options)
  end

  test "should destory main image and thumbs" do
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
