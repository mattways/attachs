require 'test_helper'

class AttachmentTest < ActiveSupport::TestCase

  test 'extras' do
    attachment.width = 300
    assert_equal 300, attachment.width
    assert_equal Hash['width', 300], attachment.extras

    attachment.save!
    attachment.reload

    assert_equal 300, attachment.width
    assert_equal Hash['width', 300], attachment.extras
  end

  test 'description' do
    assert_nil Attachs::Attachment.new.description

    attachment.record = business
    assert_equal 'Logo of Test', attachment.description
  end

  test 'url' do
    assert_nil Attachs::Attachment.new.url

    attachment.save!

    assert_equal url('1/s4rmrc8x.jpg'), attachment.url
    assert_equal url('1/orcg.jpg'), attachment.url(:tiny)
    assert_equal url('1/9n8xx.jpg'), attachment.url(:small)
    assert_equal url('1/nwurbn.jpg'), attachment.url(:medium)
    assert_equal url('1/x84mw.jpg'), attachment.url(:large)

    assert_nil attachment.url(:wrong)
  end

  test 'urls' do
    assert_equal Hash.new, Attachs::Attachment.new.urls

    attachment.save!

    assert_equal(
      { original: url('1/s4rmrc8x.jpg'),
        tiny: url('1/orcg.jpg'),
        small: url('1/9n8xx.jpg'),
        medium: url('1/nwurbn.jpg'),
        large: url('1/x84mw.jpg') },
      attachment.urls
    )
  end

  test 'requested at' do
    attachment = Attachs::Attachment.new(
      record_type: 'Business',
      record_attribute: 'logo'
    )
    assert_nil attachment.requested_at
    assert attachment.valid?
    assert_kind_of Time, attachment.requested_at
  end

  test 'record type' do
    attachment = Attachs::Attachment.new(
      record_type: 'Wrong'
    )
    assert_not attachment.valid?
    assert attachment.errors.added?(:record_type, :invalid)
  end

  test 'record attribute' do
    attachment = Attachs::Attachment.new(
      record_attribute: 'wrong'
    )
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

  private

  def attachment
    @attachment ||= Attachs::Attachment.new(
      id: 1,
      record: business,
      record_attribute: 'logo',
      extension: 'jpg',
      size: 234234,
      state: 'processed',
      content_type: 'image/jpeg',
      processed_at: (Time.zone.now + 1.hour)
    )
  end

  def business
    @business ||= Business.new(name: 'Test')
  end

end
