require 'test_helper'

class RecordTest < ActiveSupport::TestCase

  test 'inherit' do
    Subclass = Class.new(Product)
    assert_equal Product.attachments, Subclass.attachments
  end

  test 'setters' do
    product = Product.new(pictures: [image_attachment])
    picture = product.pictures.first
    assert_equal 'Product', picture.record_type
    assert_equal 'pictures', picture.record_attribute

    product = Product.new
    picture = product.pictures.build(image_attributes)
    assert_equal 'Product', picture.record_type
    assert_equal 'pictures', picture.record_attribute

    product = Product.create
    picture = product.pictures.create(image_attributes)
    assert_equal 'Product', picture.record_type
    assert_equal 'pictures', picture.record_attribute

    product = Product.new(brief: pdf_attachment)
    brief = product.brief
    assert_equal 'Product', brief.record_type
    assert_equal 'brief', brief.record_attribute

    product = Product.new
    brief = product.build_brief(pdf_attributes)
    assert_equal 'Product', brief.record_type
    assert_equal 'brief', brief.record_attribute

    product = Product.create
    brief = product.create_brief(pdf_attributes)
    assert_equal 'Product', brief.record_type
    assert_equal 'brief', brief.record_attribute
  end

end
