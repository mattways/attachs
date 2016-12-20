require 'test_helper'

class ValidationTest < ActiveSupport::TestCase
  include StorageHelper

  teardown do
    Product.clear_validators!
  end

  test 'methods' do
    %i(content_type size).each do |validator|
      method = "validates_attachment_#{validator}_of"
      assert Product.respond_to?(method)
    end
  end

  test 'presence' do
    Product.class_eval do
      validates :pictures, attachment_presence: true
      validates :brief, attachment_presence: true
    end

    product = Product.new
    assert_not product.valid?
    assert product.errors[:pictures].empty?
    assert product.errors.added?(:brief, :blank)
    assert product.brief.errors.added?(:value, :blank)

    product = Product.new(pictures: [image], brief: file)
    assert product.valid?
  end

  test 'content type with' do
    Product.class_eval do
      validates :pictures, attachment_content_type: { with: /\Aimage/ }
      validates :brief, attachment_content_type: { with: /\Atext/ }
    end

    product = Product.new(pictures: [file, image], brief: image)
    assert_not product.valid?
    assert product.errors.added?(:pictures, :invalid)
    assert product.pictures.first.errors.added?(:value, :not_allowed)
    assert product.pictures.second.valid?
    assert product.errors.added?(:brief, :not_allowed)
    assert product.brief.errors.added?(:value, :not_allowed)

    product = Product.new(pictures: [image], brief: file)
    assert product.valid?
  end

  test 'content type in' do
    Product.class_eval do
      validates :pictures, attachment_content_type: { in: %w(image/jpeg) }
      validates :brief, attachment_content_type: { in: %w(text/plain) }
    end

    product = Product.new(pictures: [file, image], brief: image)
    assert_not product.valid?
    assert product.errors.added?(:pictures, :invalid)
    assert product.pictures.first.errors.added?(:value, :can_only_be, list: 'image/jpeg')
    assert product.pictures.second.valid?
    assert product.errors.added?(:brief, :can_only_be, list: 'text/plain')
    assert product.brief.errors.added?(:value, :can_only_be, list: 'text/plain')

    product = Product.new(pictures: [image], brief: file)
    assert product.valid?
  end


  test 'content type within' do
    Product.class_eval do
      validates :pictures, attachment_content_type: { within: %w(image/jpeg) }
      validates :brief, attachment_content_type: { within: %w(text/plain) }
    end

    product = Product.new(pictures: [file, image], brief: image)
    assert_not product.valid?
    assert product.errors.added?(:pictures, :invalid)
    assert product.pictures.first.errors.added?(:value, :can_only_be, list: 'image/jpeg')
    assert product.pictures.second.valid?
    assert product.errors.added?(:brief, :can_only_be, list: 'text/plain')
    assert product.brief.errors.added?(:value, :can_only_be, list: 'text/plain')

    product = Product.new(pictures: [image], brief: file)
    assert product.valid?
  end

  test 'size in' do
    Product.class_eval do
      validates :pictures, attachment_size: { in: 15.kilobytes..250.kilobytes }
      validates :brief, attachment_size: { in: 14.bytes..500.bytes }
    end

    product = Product.new(pictures: [big_image, image], brief: big_file)
    assert_not product.valid?
    assert product.errors.added?(:pictures, :invalid)
    assert product.pictures.first.errors.added?(:value, :less_than_or_equal_to, count: humanize_size(250.kilobytes))
    assert product.pictures.second.valid?
    assert product.errors.added?(:brief, :less_than_or_equal_to, count: humanize_size(500.bytes))
    assert product.brief.errors.added?(:value, :less_than_or_equal_to, count: humanize_size(500.bytes))

    product = Product.new(pictures: [small_image, image], brief: small_file)
    assert_not product.valid?
    assert product.errors.added?(:pictures, :invalid)
    assert product.pictures.first.errors.added?(:value, :greater_than_or_equal_to, count: humanize_size(15.kilobytes))
    assert product.pictures.second.valid?
    assert product.errors.added?(:brief, :greater_than_or_equal_to, count: humanize_size(14.bytes))
    assert product.brief.errors.added?(:value, :greater_than_or_equal_to, count: humanize_size(14.bytes))

    product = Product.new(pictures: [image], brief: file)
    assert product.valid?
  end

  test 'size within' do
    Product.class_eval do
      validates :pictures, attachment_size: { within: 15.kilobytes..250.kilobytes }
      validates :brief, attachment_size: { within: 14.bytes..500.bytes }
    end

    product = Product.new(pictures: [big_image, image], brief: big_file)
    assert_not product.valid?
    assert product.errors.added?(:pictures, :invalid)
    assert product.pictures.first.errors.added?(:value, :less_than_or_equal_to, count: humanize_size(250.kilobytes))
    assert product.pictures.second.valid?
    assert product.errors.added?(:brief, :less_than_or_equal_to, count: humanize_size(500.bytes))
    assert product.brief.errors.added?(:value, :less_than_or_equal_to, count: humanize_size(500.bytes))

    product = Product.new(pictures: [small_image, image], brief: small_file)
    assert_not product.valid?
    assert product.errors.added?(:pictures, :invalid)
    assert product.pictures.first.errors.added?(:value, :greater_than_or_equal_to, count: humanize_size(15.kilobytes))
    assert product.pictures.second.valid?
    assert product.errors.added?(:brief, :greater_than_or_equal_to, count: humanize_size(14.bytes))
    assert product.brief.errors.added?(:value, :greater_than_or_equal_to, count: humanize_size(14.bytes))

    product = Product.new(pictures: [image], brief: file)
    assert product.valid?
  end

  test 'size less than' do
    Product.class_eval do
      validates :pictures, attachment_size: { less_than: 250.kilobytes }
      validates :brief, attachment_size: { less_than: 500.bytes }
    end

    product = Product.new(pictures: [big_image, image], brief: big_file)
    assert_not product.valid?
    assert product.errors.added?(:pictures, :invalid)
    assert product.pictures.first.errors.added?(:value, :less_than, count: humanize_size(250.kilobytes))
    assert product.pictures.second.valid?
    assert product.errors.added?(:brief, :less_than, count: humanize_size(500.bytes))
    assert product.brief.errors.added?(:value, :less_than, count: humanize_size(500.bytes))

    product = Product.new(pictures: [image], brief: file)
    assert product.valid?
  end

  test 'size greater than' do
    Product.class_eval do
      validates :pictures, attachment_size: { greater_than: 15.kilobytes }
      validates :brief, attachment_size: { greater_than: 14.bytes }
    end

    product = Product.new(pictures: [small_image, image], brief: small_file)
    assert_not product.valid?
    assert product.errors.added?(:pictures, :invalid)
    assert product.pictures.first.errors.added?(:value, :greater_than, count: humanize_size(15.kilobytes))
    assert product.pictures.second.valid?
    assert product.errors.added?(:brief, :greater_than, count: humanize_size(14.bytes))
    assert product.brief.errors.added?(:value, :greater_than, count: humanize_size(14.bytes))

    product = Product.new(pictures: [image], brief: file)
    assert product.valid?
  end

end
