require 'test_helper'

class CallbackTest < ActiveSupport::TestCase

  test 'process' do
    file = image_file
    attachment = build(:image)

    assert_nothing_raised do
      callbacks.process :before_process, file, attachment
    end

    callbacks.process :after_process, file, attachment
    assert_equal 400, attachment.width
    assert_equal 269, attachment.height
    assert_equal 0.6725, attachment.ratio
  end

  test 'add' do
    assert_raises Attachs::CallbackNotFound do
      callbacks.add :other, /text\// do |file, attachment|
      end
    end
  end

  private

  def callbacks
    Attachs.configuration.callbacks
  end

end
