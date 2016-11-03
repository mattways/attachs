require 'test_helper'

class ConcernTest < ActiveSupport::TestCase

  test 'inherit' do
    Subclass = Class.new(Product)
    assert_equal Product.attachments, Subclass.attachments
  end

end
