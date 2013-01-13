require 'test_helper'

class ImageStringTest < ActiveSupport::TestCase

  setup :create_image

  test "should destory main image and thumbs" do

    original = @image.realpath
    big = @image.realpath(:big)
    small = @image.realpath(:small)
    
    @image.delete
    
    assert !::File.exists?(original)
    assert !::File.exists?(big)
    assert !::File.exists?(small)
  
  end

  protected

  def create_image
    filename = 'image.jpg'
    FileUtils.cp File.join(ActiveSupport::TestCase.fixture_path, filename), Rails.root.join('public', 'uploads', filename)
    FileUtils.cp File.join(ActiveSupport::TestCase.fixture_path, filename), Rails.root.join('public', 'uploads', filename.gsub('.', '-big.'))
    FileUtils.cp File.join(ActiveSupport::TestCase.fixture_path, filename), Rails.root.join('public', 'uploads', filename.gsub('.', '-small.'))
    @options = { :presets => { :big => { :method => :fit, :width => 1024, :height => 768  }, :small => { :method => :center, :width => 120, :height => 120 } } }
    @image = RailsUploads::Types::Image.new(filename, @options)
  end

end
