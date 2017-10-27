require 'test_helper'

class HelperTest < ActionView::TestCase
  include Attachs::Extensions::ActionView::Base

  test 'image tag' do
    assert_equal(
      '<img src="/images/test.jpg" alt="Test" />',
      image_tag('test.jpg')
    )
    assert_equal(
      %Q{<img alt="Logo of Test" src="#{url('1/s4rmrc8x.jpg')}" />},
      image_tag(attachment)
    )
    assert_equal(
      %Q{<img alt="Logo of Test" src="#{url('1/orcg.jpg')}" />},
      image_tag(attachment, style: :tiny)
    )
  end

  private

  def attachment
    @attachment ||= Attachs::Attachment.create(
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
