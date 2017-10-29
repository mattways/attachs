require 'test_helper'

class HelperTest < ActionView::TestCase
  include Attachs::Extensions::ActionView::Base

  test 'image tag' do
    assert_equal(
      '<img src="/images/test.jpg" alt="Test" />',
      image_tag('test.jpg')
    )

    attachment = create(:image, :processed, :attached)
    assert_equal(
      %Q{<img alt="Logo of Test" src="#{attachment.url}" />},
      image_tag(attachment)
    )
    assert_equal(
      %Q{<img alt="Logo of Test" src="#{attachment.url(:tiny)}" />},
      image_tag(attachment, style: :tiny)
    )
  end

end
