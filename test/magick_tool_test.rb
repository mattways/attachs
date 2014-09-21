require 'test_helper'

class MagickToolTest < ActiveSupport::TestCase

  teardown do
    Dir[Rails.root.join('tmp', '*')].each do |file|
      File.delete file
    end
  end

  test 'force resize' do
    Attachs::Tools::Magick.resize(source, :big_force, resized)
    assert_equal [160,130], Attachs::Tools::Magick.dimensions(resized)
    Attachs::Tools::Magick.resize(resized, :small_force)
    assert_equal [140,110], Attachs::Tools::Magick.dimensions(resized)
  end

  test 'cover resize' do
    Attachs::Tools::Magick.resize(source, :big_cover, resized)
    assert_equal [160, 130], Attachs::Tools::Magick.dimensions(resized)
    Attachs::Tools::Magick.resize(resized, :small_cover)
    assert_equal [140,110], Attachs::Tools::Magick.dimensions(resized)
  end

  test 'contain resize' do
    Attachs::Tools::Magick.resize(source, :big_contain, resized)
    assert_equal [156, 130], Attachs::Tools::Magick.dimensions(resized)
    Attachs::Tools::Magick.resize(resized, :small_contain)
    assert_equal [132,110], Attachs::Tools::Magick.dimensions(resized)
  end

  private

  def source
    image_upload.path
  end

  def resized
    Rails.root.join('tmp', 'resized.gif')
  end

end
