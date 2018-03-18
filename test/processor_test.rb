require 'test_helper'

class ProcessorTest < ActiveSupport::TestCase

  teardown do
    clear_tmp
  end

  test 'force' do
    processor.process destination_path, '300x100!'
    assert_equal [300, 100], console.dimensions(destination_path)
  end

  test 'cover' do
    processor.process destination_path, '400x100#'
    assert_equal [400, 100], console.dimensions(destination_path)
  end

  test 'contain' do
    processor.process destination_path, '300x100'
    assert_equal [149, 100], console.dimensions(destination_path)
  end

  private

  def processor
    @processor ||= Attachs::Processors::Image.new(image_path)
  end

  def destination_path
    File.join tmp_path, 'test.png'
  end

end
