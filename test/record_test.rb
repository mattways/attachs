require 'test_helper'

class RecordTest < ActiveSupport::TestCase

  test 'inherit' do
    Subclass = Class.new(Product)
    assert_equal Product.attachments, Subclass.attachments
  end

  test 'setters' do
    attachment = build(:attachment)
    image = build(:image, :processed)

    product = build(:product, pictures: [attachment.dup])
    picture = product.pictures.first
    assert_equal 'Product', picture.record_type
    assert_equal 'pictures', picture.record_attribute
    product.save!
    assert_not product.pictures.first.persisted?

    product = build(:product)
    picture = product.pictures.build(attachment.attributes)
    assert_equal 'Product', picture.record_type
    assert_equal 'pictures', picture.record_attribute
    product.save!
    assert_not product.pictures.first.persisted?

    product = create(:product)
    picture = product.pictures.create(image.attributes)
    assert_equal 'Product', picture.record_type
    assert_equal 'pictures', picture.record_attribute

    product = build(:product)
    brief = product.brief
    assert_equal 'Product', brief.record_type
    assert_equal 'brief', brief.record_attribute
    product.save!
    assert_not product.brief.persisted?

    product = build(:product)
    brief = product.brief = attachment.dup
    assert_equal 'Product', brief.record_type
    assert_equal 'brief', brief.record_attribute
    product.save!
    assert_not product.brief.persisted?

    product = build(:product)
    brief = product.build_brief(attachment.attributes)
    assert_equal 'Product', brief.record_type
    assert_equal 'brief', brief.record_attribute
    product.save!
    assert_not product.brief.persisted?

    product = build(:product)
    brief = product.create_brief(image.attributes)
    assert_equal 'Product', brief.record_type
    assert_equal 'brief', brief.record_attribute
  end

end
