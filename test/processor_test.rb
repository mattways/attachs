require 'test_helper'

class ProcessorTest < ActiveSupport::TestCase

  teardown do
    Dir[Rails.root.join('tmp', '*')].each do |file|
      File.delete file
    end
  end

  test 'force resize' do
    Attachs::Processors::Thumbnail.new(nil, source).process(:big_force, resized)
    assert_equal [160,130], dimensions(resized)
    Attachs::Processors::Thumbnail.new(nil, source).process(:small_force, resized)
    assert_equal [140,110], dimensions(resized)
  end

  test 'cover resize' do
    Attachs::Processors::Thumbnail.new(nil, source).process(:big_cover, resized)
    assert_equal [160,130], dimensions(resized)
    Attachs::Processors::Thumbnail.new(nil, source).process(:small_cover, resized)
    assert_equal [140,110], dimensions(resized)
  end

  test 'contain resize' do
    Attachs::Processors::Thumbnail.new(nil, source).process(:big_contain, resized)
    assert_equal [156,130], dimensions(resized)
    Attachs::Processors::Thumbnail.new(nil, source).process(:small_contain, resized)
    assert_equal [132,110], dimensions(resized)
  end

  private

  def source
    image_upload.path
  end

  def resized
    Rails.root.join('public', 'resized.gif')
  end

  def dimensions(source)
    `identify -format %wx%h '#{source}'`.split('x').map(&:to_i)
  end

end
