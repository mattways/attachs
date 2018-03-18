require 'test_helper'

class ConsoleTest < ActiveSupport::TestCase

  teardown do
    clear_tmp
  end

  test 'detect content type' do
    assert_equal 'image/jpeg', console.content_type(image_path)
  end

  test 'read dimensions' do
    assert_equal [400, 269], console.dimensions(image_path)
  end

  test 'identical' do
    FileUtils.copy image_path, destination_path
    assert console.identical?(image_path, destination_path)
  end

  test 'convert' do
    console.convert image_path, destination_path
    assert File.exist?(destination_path)
  end

  private

  def destination_path
    File.join tmp_path, 'test.png'
  end

end
