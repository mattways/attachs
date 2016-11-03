require 'test_helper'

class AttachmentTest < ActiveSupport::TestCase
  include StorageHelper

  test 'nested attributes' do
    product = Product.new(pictures: [image])
    product.brief_attributes = { value: file }
    product.pictures_attributes = [
      { id: product.pictures.first.id, _destroy: '1' },
      { value: image }
    ]

    assert product.pictures.first.blank?
    assert product.pictures.second.present?
    assert product.brief.present?
  end

  test 'attributes' do
    shop = Shop.new
    attachment = shop.logo

    assert_nil attachment.id
    assert_nil attachment.filename
    assert_nil attachment.basename
    assert_nil attachment.extension
    assert_nil attachment.content_type
    assert_nil attachment.type
    assert_nil attachment.size
    assert_nil attachment.uploaded_at
    assert_equal Hash[tiny: '25x25', small: '150x150#', medium: '300x300!', large: '600x'], attachment.styles
    assert_not attachment.changed?
    assert_not attachment.present?
    assert_not attachment.persisted?
    assert attachment.blank?
    assert_raises { attachment.width }
    assert_raises { attachment.height }
    assert_raises { attachment.ratio }
    assert_nil attachment.url
    assert_nil attachment.url(:tiny)

    shop.logo = image
    attachment = shop.logo

    assert attachment.id
    assert_equal 'image.jpg', attachment.filename
    assert_equal 'image', attachment.basename
    assert_equal '.jpg', attachment.extension
    assert_equal 'image/jpeg', attachment.content_type
    assert_equal 'image', attachment.type
    assert_equal 74474, attachment.size
    assert_equal Date.today, attachment.uploaded_at.to_date
    assert_equal Hash[tiny: '25x25', small: '150x150#', medium: '300x300!', large: '600x'], attachment.styles
    assert attachment.changed?
    assert attachment.present?
    assert_not attachment.blank?
    assert_not attachment.persisted?
    assert_equal 400, attachment.width
    assert_equal 269, attachment.height
    assert_equal (269.0 / 400.0), attachment.ratio
    assert_nil attachment.url
    assert_nil attachment.url(:tiny)

    shop.save!
    shop.run_callbacks :commit
    shop.reload
    attachment = shop.logo

    assert attachment.id
    assert_equal 'image.jpg', attachment.filename
    assert_equal 'image', attachment.basename
    assert_equal '.jpg', attachment.extension
    assert_equal 'image/jpeg', attachment.content_type
    assert_equal 'image', attachment.type
    assert_equal 74474, attachment.size
    assert_equal Date.today, attachment.uploaded_at.to_date
    assert_equal Hash[tiny: '25x25', small: '150x150#', medium: '300x300!', large: '600x'], attachment.styles
    assert_not attachment.changed?
    assert attachment.present?
    assert attachment.persisted?
    assert_not attachment.blank?
    assert_equal 400, attachment.width
    assert_equal 269, attachment.height
    assert_equal (269.0 / 400.0), attachment.ratio
    assert_equal "https://s3.amazonaws.com/attachs.test/#{attachment.id}-original.png", attachment.url
    assert_equal "https://s3.amazonaws.com/attachs.test/#{attachment.id}-tiny.png", attachment.url(:tiny)
    assert_equal "https://s3.amazonaws.com/attachs.test/#{attachment.id}-small.png", attachment.url(:small)
    assert_equal "https://s3.amazonaws.com/attachs.test/#{attachment.id}-medium.png", attachment.url(:medium)
    assert_equal "https://s3.amazonaws.com/attachs.test/#{attachment.id}-large.png", attachment.url(:large)
    assert_url_content_type 'image/png', attachment.url
    assert_url_dimensions '400x269', attachment.url
    assert_url_content_type 'image/png', attachment.url(:tiny)
    assert_url_dimensions '25x17', attachment.url(:tiny)
    assert_url_content_type 'image/png', attachment.url(:small)
    assert_url_dimensions '150x150', attachment.url(:small)
    assert_url_content_type 'image/png', attachment.url(:medium)
    assert_url_dimensions '300x300', attachment.url(:medium)
    assert_url_content_type 'image/png', attachment.url(:large)
    assert_url_dimensions '600x404', attachment.url(:large)

    saved_attachment = attachment.dup
    shop.destroy
    shop.run_callbacks :commit

    assert_nil attachment.id
    assert_nil attachment.filename
    assert_nil attachment.basename
    assert_nil attachment.extension
    assert_nil attachment.content_type
    assert_nil attachment.type
    assert_nil attachment.size
    assert_nil attachment.uploaded_at
    assert_equal Hash[tiny: '25x25', small: '150x150#', medium: '300x300!', large: '600x'], attachment.styles
    assert_not attachment.changed?
    assert_not attachment.present?
    assert_not attachment.persisted?
    assert attachment.blank?
    assert_raises { attachment.width }
    assert_raises { attachment.height }
    assert_raises { attachment.ratio }
    sleep 5
    assert_not_url saved_attachment.url
    assert_not_url saved_attachment.url(:tiny)
    assert_not_url saved_attachment.url(:small)
    assert_not_url saved_attachment.url(:medium)
    assert_not_url saved_attachment.url(:large)
  end

  test 'renames' do
    shop = Shop.create(logo: image, name: 'Anderstons')
    shop.run_callbacks :commit
    attachment = shop.logo

    assert_equal "https://s3.amazonaws.com/attachs.test/anderstons/#{attachment.id}-original.png", attachment.url
    assert_equal "https://s3.amazonaws.com/attachs.test/anderstons/#{attachment.id}-tiny.png", attachment.url(:tiny)
    assert_equal "https://s3.amazonaws.com/attachs.test/anderstons/#{attachment.id}-small.png", attachment.url(:small)
    assert_equal "https://s3.amazonaws.com/attachs.test/anderstons/#{attachment.id}-medium.png", attachment.url(:medium)
    assert_equal "https://s3.amazonaws.com/attachs.test/anderstons/#{attachment.id}-large.png", attachment.url(:large)
    assert_url attachment.url
    assert_url attachment.url(:tiny)
    assert_url attachment.url(:small)
    assert_url attachment.url(:medium)
    assert_url attachment.url(:large)

    original_attachment = attachment.dup
    shop.update! name: 'Musicians Friend'
    shop.run_callbacks :commit
    shop.reload
    attachment = shop.logo

    sleep 5
    assert_equal "https://s3.amazonaws.com/attachs.test/musicians-friend/#{attachment.id}-original.png", attachment.url
    assert_equal "https://s3.amazonaws.com/attachs.test/musicians-friend/#{attachment.id}-tiny.png", attachment.url(:tiny)
    assert_equal "https://s3.amazonaws.com/attachs.test/musicians-friend/#{attachment.id}-small.png", attachment.url(:small)
    assert_equal "https://s3.amazonaws.com/attachs.test/musicians-friend/#{attachment.id}-medium.png", attachment.url(:medium)
    assert_equal "https://s3.amazonaws.com/attachs.test/musicians-friend/#{attachment.id}-large.png", attachment.url(:large)
    assert_url attachment.url
    assert_url attachment.url(:tiny)
    assert_url attachment.url(:small)
    assert_url attachment.url(:medium)
    assert_url attachment.url(:large)
    assert_url original_attachment.url
    assert_url original_attachment.url(:tiny)
    assert_url original_attachment.url(:small)
    assert_url original_attachment.url(:medium)
    assert_url original_attachment.url(:large)

    renamed_attachment = attachment.dup
    shop.destroy
    shop.run_callbacks :commit

    sleep 5
    assert_not_url renamed_attachment.url
    assert_not_url renamed_attachment.url(:tiny)
    assert_not_url renamed_attachment.url(:small)
    assert_not_url renamed_attachment.url(:medium)
    assert_not_url renamed_attachment.url(:large)
    assert_not_url original_attachment.url
    assert_not_url original_attachment.url(:tiny)
    assert_not_url original_attachment.url(:small)
    assert_not_url original_attachment.url(:medium)
    assert_not_url original_attachment.url(:large)
  end

end
