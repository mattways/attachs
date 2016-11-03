require 'test_helper'

class CollectionTest < ActiveSupport::TestCase
  include StorageHelper

  setup do
    @product = Product.create(pictures: [image, image])
    @product.run_callbacks :commit
  end

  teardown do
    @product.pictures.destroy
  end

  test 'size' do
    assert_equal 2, @product.pictures.size
  end

  test 'index' do
    attachment1 = @product.pictures.first
    attachment2 = @product.pictures.second
    attachment2.position = 0
    assert_equal attachment2.id, @product.pictures.first.id
    assert_equal attachment1.id, @product.pictures.second.id
    @product.save
    @product.reload
    assert_equal attachment2.id, @product.pictures.first.id
    assert_equal attachment1.id, @product.pictures.second.id
  end

end
