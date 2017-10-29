require 'test_helper'

class AttachmentTest < ActiveSupport::TestCase

  test 'extras' do
    attachment = build(:image, width: 300)
    assert_equal 300, attachment.width
    assert_equal Hash['width', 300], attachment.extras

    attachment.save!
    attachment.reload

    assert_equal 300, attachment.width
    assert_equal Hash['width', 300], attachment.extras
  end

  test 'description' do
    attachment = build(:attachment)
    assert_nil attachment.description

    attachment = build(:image, :attached)
    assert_equal 'Logo of Test', attachment.description
  end

  test 'url' do
    attachment = build(:attachment)
    assert_nil attachment.url

    attachment = create(:image, :processed)
    assert_equal url("#{attachment.id}/s4rmrc8x.jpg"), attachment.url
    assert_equal url("#{attachment.id}/orcg.jpg"), attachment.url(:tiny)
    assert_equal url("#{attachment.id}/9n8xx.jpg"), attachment.url(:small)
    assert_equal url("#{attachment.id}/nwurbn.jpg"), attachment.url(:medium)
    assert_equal url("#{attachment.id}/x84mw.jpg"), attachment.url(:large)
    assert_nil attachment.url(:wrong)
  end

  test 'urls' do
    attachment = build(:attachment)
    assert_equal Hash.new, attachment.urls

    attachment = create(:image, :processed)
    assert_equal(
      Hash[
        original: url("#{attachment.id}/s4rmrc8x.jpg"),
        tiny: url("#{attachment.id}/orcg.jpg"),
        small: url("#{attachment.id}/9n8xx.jpg"),
        medium: url("#{attachment.id}/nwurbn.jpg"),
        large: url("#{attachment.id}/x84mw.jpg")
      ],
      attachment.urls
    )
  end

  test 'requested at' do
    attachment = build(:image)
    assert_nil attachment.requested_at
    assert attachment.valid?
    assert_kind_of Time, attachment.requested_at
  end

  test 'record type' do
    attachment = build(:attachment, record_type: 'Wrong')
    assert_not attachment.valid?
    assert attachment.errors.added?(:record_type, :invalid)
  end

  test 'record attribute' do
    attachment = build(:attachment, record_attribute: 'wrong')
    assert_not attachment.valid?
    assert attachment.errors.added?(:record_attribute, :invalid)
  end

=begin
  test 'process' do
    upload = Attachs::Upload.new(path: 'image.jpg', style: 'original')
    attachment = Attachs::Attachment.new(uploads: [upload])
    business = Business.new(logo: attachment)

    assert business.valid?
    assert business.save

    attachment.process
  end
=end

  test 'reprocess' do

  end

  test 'fix missings' do

  end

end
