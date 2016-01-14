require 'test_helper'

class ProcessorTest < ActiveSupport::TestCase

  setup do
    FileUtils.cp source_path, resized_path
  end

  teardown do
    FileUtils.rm_rf resized_path
  end

  test 'force resize' do
    Attachs::Processors::Thumbnail.new(nil, source_path).process(:big_force, resized_path)
    assert_equal [160,130], dimensions(resized_path)
    Attachs::Processors::Thumbnail.new(nil, source_path).process(:small_force, resized_path)
    assert_equal [140,110], dimensions(resized_path)
  end

  test 'cover resize' do
    Attachs::Processors::Thumbnail.new(nil, source_path).process(:big_cover, resized_path)
    assert_equal [160,130], dimensions(resized_path)
    Attachs::Processors::Thumbnail.new(nil, source_path).process(:small_cover, resized_path)
    assert_equal [140,110], dimensions(resized_path)
  end

  test 'contain resize' do
    Attachs::Processors::Thumbnail.new(nil, source_path).process(:big_contain, resized_path)
    assert_equal [156,130], dimensions(resized_path)
    Attachs::Processors::Thumbnail.new(nil, source_path).process(:small_contain, resized_path)
    assert_equal [132,110], dimensions(resized_path)
  end

  private

  def source_path
    image_upload.path
  end

  def resized_path
    Rails.root.join('tmp/resized.gif')
  end

  def dimensions(source)
    `identify -format %wx%h '#{source}'`.split('x').map(&:to_i)
  end

end
