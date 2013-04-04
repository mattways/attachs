require 'test_helper'

class ImageStringTest < ActiveSupport::TestCase

  setup :create_image

  test 'should destory main image and thumbs' do

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
    FileUtils.mkdir_p Rails.root.join('public', 'uploads', 'images', 'original')
    FileUtils.mkdir_p Rails.root.join('public', 'uploads', 'images', 'big')
    FileUtils.mkdir_p Rails.root.join('public', 'uploads', 'images', 'small')
    filename = 'image.jpg'
    fixture = ::File.join(ActiveSupport::TestCase.fixture_path, filename)
    FileUtils.cp fixture, Rails.root.join('public', 'uploads', 'images', 'original', filename)
    FileUtils.cp fixture, Rails.root.join('public', 'uploads', 'images', 'big', filename)
    FileUtils.cp fixture, Rails.root.join('public', 'uploads', 'images', 'small', filename)
    @options = { :presets => [:small, :big] }
    @image = Rails::Uploads::Types::Image.new(filename, @options)
  end

end
