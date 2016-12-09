require 'test_helper'

class RecordTest < ActiveSupport::TestCase
  include StorageHelper

  test 'inherit' do
    Subclass = Class.new(Product)
    assert_equal Product.attachments, Subclass.attachments
  end

  test 'clear attachments' do
    shop = Shop.new(logo: image).dup
    assert shop.logo.source.blank?

    shop = Shop.create(logo: image).reload
    assert shop.logo.source.blank?
  end

end
