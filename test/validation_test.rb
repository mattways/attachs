require 'test_helper'

class ValidationTest < ActiveSupport::TestCase

  teardown do
    Product.clear_validators!
  end

  test 'methods' do
    %i(content_type size).each do |validator|
      method = "validates_attachment_#{validator}_of"
      assert Product.respond_to?(method)
    end
  end

  test 'content type with' do
    Product.class_eval do
      validates :pictures, attachment_content_type: { with: /\Aimage/ }
      validates :brief, attachment_content_type: { with: /\Aapplication\/pdf\z/ }
    end

    pdf = build(:pdf, :processed)
    image = build(:image, :processed)

    product = build(:product, pictures: [pdf.dup, image.dup], brief: image.dup)
    assert_not product.valid?
    assert product.errors.added?(:pictures, :invalid)
    assert product.pictures.first.errors.added?(:content_type, :unallowed)
    assert product.pictures.second.errors.none?
    assert product.errors.added?(:brief, :invalid)
    assert product.brief.errors.added?(:content_type, :unallowed)

    product = build(:product, pictures: [image.dup], brief: pdf.dup)
    assert product.valid?
  end

  test 'content type is' do
    Product.class_eval do
      validates :pictures, attachment_content_type: { is: 'image/jpeg' }
      validates :brief, attachment_content_type: { is: 'application/pdf' }
    end

    pdf = build(:pdf, :processed)
    image = build(:image, :processed)

    product = build(:product, pictures: [pdf.dup, image.dup], brief: image.dup)
    assert_not product.valid?
    assert product.errors.added?(:pictures, :invalid)
    assert product.pictures.first.errors.added?(:content_type, :allowed_list, list: 'image/jpeg')
    assert product.pictures.second.errors.none?
    assert product.errors.added?(:brief, :invalid)
    assert product.brief.errors.added?(:content_type, :allowed_list, list: 'application/pdf')

    product = build(:product, pictures: [image.dup], brief: pdf.dup)
    assert product.valid?
  end

  test 'content type in' do
    Product.class_eval do
      validates :pictures, attachment_content_type: { in: %w(image/jpeg) }
      validates :brief, attachment_content_type: { in: %w(application/pdf) }
    end

    pdf = build(:pdf, traits: :processed)
    image = build(:image, :processed)

    product = build(:product, pictures: [pdf.dup, image.dup], brief: image.dup)
    assert_not product.valid?
    assert product.errors.added?(:pictures, :invalid)
    assert product.pictures.first.errors.added?(:content_type, :allowed_list, list: 'image/jpeg')
    assert product.pictures.second.errors.none?
    assert product.errors.added?(:brief, :invalid)
    assert product.brief.errors.added?(:content_type, :allowed_list, list: 'application/pdf')

    product = build(:product, pictures: [image.dup], brief: pdf.dup)
    assert product.valid?
  end

  test 'content type within' do
    Product.class_eval do
      validates :pictures, attachment_content_type: { within: %w(image/jpeg) }
      validates :brief, attachment_content_type: { within: %w(application/pdf) }
    end

    pdf = build(:pdf, :processed)
    image = build(:image, :processed)

    product = build(:product, pictures: [pdf.dup, image.dup], brief: image.dup)
    assert_not product.valid?
    assert product.errors.added?(:pictures, :invalid)
    assert product.pictures.first.errors.added?(:content_type, :allowed_list, list: 'image/jpeg')
    assert product.pictures.second.errors.none?
    assert product.errors.added?(:brief, :invalid)
    assert product.brief.errors.added?(:content_type, :allowed_list, list: 'application/pdf')

    product = build(:product, pictures: [image.dup], brief: pdf.dup)
    assert product.valid?
  end

  test 'size greater than' do
    Product.class_eval do
      validates :pictures, attachment_size: { greater_than: 100.kilobytes }
      validates :brief, attachment_size: { greater_than: 200.bytes }
    end

    small_image = build(:image, :processed, size: 50.kilobytes)
    big_image = build(:image, :processed, size: 150.kilobytes)
    small_pdf = build(:pdf, :processed, size: 100.bytes)
    big_pdf = build(:pdf, :processed, size: 300.bytes)

    product = build(:product, pictures: [small_image.dup, big_image.dup], brief: small_pdf.dup)
    assert_not product.valid?
    assert product.errors.added?(:pictures, :invalid)
    assert product.pictures.first.errors.added?(:size, :greater_than, count: humanize_size(100.kilobytes))
    assert product.pictures.second.errors.none?
    assert product.errors.added?(:brief, :invalid)
    assert product.brief.errors.added?(:size, :greater_than, count: humanize_size(200.bytes))

    product = build(:product, pictures: [big_image.dup], brief: big_pdf.dup)
    assert product.valid?
  end

  test 'size less than' do
    Product.class_eval do
      validates :pictures, attachment_size: { less_than: 200.kilobytes }
      validates :brief, attachment_size: { less_than: 400.bytes }
    end

    small_image = build(:image, :processed, size: 150.kilobytes)
    big_image = build(:image, :processed, size: 250.kilobytes)
    small_pdf = build(:pdf, :processed, size: 300.bytes)
    big_pdf = build(:pdf, :processed, size: 500.bytes)

    product = build(:product, pictures: [big_image.dup, small_image.dup], brief: big_pdf.dup)
    assert_not product.valid?
    assert product.errors.added?(:pictures, :invalid)
    assert product.pictures.first.errors.added?(:size, :less_than, count: humanize_size(200.kilobytes))
    assert product.pictures.second.errors.none?
    assert product.errors.added?(:brief, :invalid)
    assert product.brief.errors.added?(:size, :less_than, count: humanize_size(400.bytes))

    product = build(:product, pictures: [small_image.dup], brief: small_pdf.dup)
    assert product.valid?
  end

  test 'size equal to' do
    Product.class_eval do
      validates :pictures, attachment_size: { equal_to: 150.kilobytes }
      validates :brief, attachment_size: { equal_to: 300.bytes }
    end

    small_image = build(:image, :processed, size: 150.kilobytes)
    big_image = build(:image, :processed, size: 250.kilobytes)
    small_pdf = build(:pdf, :processed, size: 100.bytes)
    big_pdf = build(:pdf, :processed, size: 300.bytes)

    product = build(:product, pictures: [big_image.dup, small_image.dup], brief: small_pdf.dup)
    assert_not product.valid?
    assert product.errors.added?(:pictures, :invalid)
    assert product.pictures.first.errors.added?(:size, :equal_to, count: humanize_size(150.kilobytes))
    assert product.pictures.second.errors.none?
    assert product.errors.added?(:brief, :invalid)
    assert product.brief.errors.added?(:size, :equal_to, count: humanize_size(300.bytes))

    product = build(:product, pictures: [small_image.dup], brief: big_pdf.dup)
    assert product.valid?
  end

  test 'size other than' do
    Product.class_eval do
      validates :pictures, attachment_size: { other_than: 200.kilobytes }
      validates :brief, attachment_size: { other_than: 400.bytes }
    end

    small_image = build(:image, :processed, size: 150.kilobytes)
    big_image = build(:image, :processed, size: 200.kilobytes)
    small_pdf = build(:pdf, :processed, size: 300.bytes)
    big_pdf = build(:pdf, :processed, size: 400.bytes)

    product = build(:product, pictures: [big_image.dup, small_image.dup], brief: big_pdf.dup)
    assert_not product.valid?
    assert product.errors.added?(:pictures, :invalid)
    assert product.pictures.first.errors.added?(:size, :other_than, count: humanize_size(200.kilobytes))
    assert product.pictures.second.errors.none?
    assert product.errors.added?(:brief, :invalid)
    assert product.brief.errors.added?(:size, :other_than, count: humanize_size(400.bytes))

    product = build(:product, pictures: [small_image.dup], brief: small_pdf.dup)
    assert product.valid?
  end

  test 'size in' do
    Product.class_eval do
      validates :pictures, attachment_size: { in: 100.kilobytes..200.kilobytes }
      validates :brief, attachment_size: { in: 200.bytes..400.bytes }
    end

    small_image = build(:image, :processed, size: 50.kilobytes)
    medium_image = build(:image, :processed, size: 150.kilobytes)
    big_image = build(:image, :processed, size: 250.kilobytes)
    small_pdf = build(:pdf, :processed, size: 100.bytes)
    medium_pdf = build(:pdf, :processed, size: 300.bytes)
    big_pdf = build(:pdf, :processed, size: 500.bytes)

    product = build(:product, pictures: [big_image.dup, medium_image.dup], brief: big_pdf)
    assert_not product.valid?
    assert product.errors.added?(:pictures, :invalid)
    assert product.pictures.first.errors.added?(:size, :less_than_or_equal_to, count: humanize_size(200.kilobytes))
    assert product.pictures.second.errors.none?
    assert product.errors.added?(:brief, :invalid)
    assert product.brief.errors.added?(:size, :less_than_or_equal_to, count: humanize_size(400.bytes))

    product = build(:product, pictures: [small_image.dup, medium_image.dup], brief: small_pdf.dup)
    assert_not product.valid?
    assert product.errors.added?(:pictures, :invalid)
    assert product.pictures.first.errors.added?(:size, :greater_than_or_equal_to, count: humanize_size(100.kilobytes))
    assert product.pictures.second.errors.none?
    assert product.errors.added?(:brief, :invalid)
    assert product.brief.errors.added?(:size, :greater_than_or_equal_to, count: humanize_size(200.bytes))

    product = build(:product, pictures: [medium_image.dup], brief: medium_pdf.dup)
    assert product.valid?
  end

  test 'size within' do
    Product.class_eval do
      validates :pictures, attachment_size: { within: 100.kilobytes..200.kilobytes }
      validates :brief, attachment_size: { within: 200.bytes..400.bytes }
    end

    small_image = build(:image, :processed, size: 50.kilobytes)
    medium_image = build(:image, :processed, size: 150.kilobytes)
    big_image = build(:image, :processed, size: 250.kilobytes)
    small_pdf = build(:pdf, :processed, size: 100.bytes)
    medium_pdf = build(:pdf, :processed, size: 300.bytes)
    big_pdf = build(:pdf, :processed, size: 500.bytes)

    product = build(:product, pictures: [big_image.dup, medium_image.dup], brief: big_pdf.dup)
    assert_not product.valid?
    assert product.errors.added?(:pictures, :invalid)
    assert product.pictures.first.errors.added?(:size, :less_than_or_equal_to, count: humanize_size(200.kilobytes))
    assert product.pictures.second.errors.none?
    assert product.errors.added?(:brief, :invalid)
    assert product.brief.errors.added?(:size, :less_than_or_equal_to, count: humanize_size(400.bytes))

    product = build(:product, pictures: [small_image.dup, medium_image.dup], brief: small_pdf.dup)
    assert_not product.valid?
    assert product.errors.added?(:pictures, :invalid)
    assert product.pictures.first.errors.added?(:size, :greater_than_or_equal_to, count: humanize_size(100.kilobytes))
    assert product.pictures.second.errors.none?
    assert product.errors.added?(:brief, :invalid)
    assert product.brief.errors.added?(:size, :greater_than_or_equal_to, count: humanize_size(200.bytes))

    product = build(:product, pictures: [medium_image.dup], brief: medium_pdf.dup)
    assert product.valid?
  end

  private

  def humanize_size(size)
    ActiveSupport::NumberHelper.number_to_human_size size
  end

end
