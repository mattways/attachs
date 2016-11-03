require 'test_helper'

class QueryTest < ActiveSupport::TestCase
  include StorageHelper

  test 'exist' do
    shop = Shop.create(name: 'first', logo: image)
    shop.run_callbacks :commit
    shop_old_path = shop.logo.paths[:original]
    shop.update name: 'second'
    shop.run_callbacks :commit
    shop_path = shop.logo.paths[:original]

    product = Product.create(pictures: [image, image])
    product.run_callbacks :commit
    product_path = product.pictures.first.paths[:original]

    assert Attachs.exists?(shop_old_path)
    assert Attachs.exists?(shop_path)
    assert Attachs.exists?(product_path)

    shop.logo.destroy
    product.pictures.destroy
  end

end
