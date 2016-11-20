require 'test_helper'

class CollectionTest < ActiveSupport::TestCase
  include StorageHelper

  test 'nested attributes' do
    product = Product.new(pictures: [image])
    product.pictures_attributes = [
      { id: product.pictures.first.id, _destroy: '1' },
      { value: image }
    ]

    assert product.pictures.first.blank?
    assert product.pictures.second.present?
  end

  test 'attributes' do
    product = Product.new(pictures: [image])
    assert_equal 1, product.pictures.size

    product.pictures.new
    assert_equal 2, product.pictures.size

    product.pictures[1] = image
    assert_equal 2, product.pictures.size

    product.save
    product.run_callbacks :commit
    product.reload

    assert_equal 2, product.pictures.size

    product.pictures.destroy
  end

  test 'index' do
    product = Product.new(pictures: [image, image])
    attachment1 = product.pictures.first
    attachment2 = product.pictures.second
    attachment2.position = 0

    assert_equal attachment2.id, product.pictures.first.id
    assert_equal attachment1.id, product.pictures.second.id

    product.save
    product.reload

    assert_equal attachment2.id, product.pictures.first.id
    assert_equal attachment1.id, product.pictures.second.id
  end

end
