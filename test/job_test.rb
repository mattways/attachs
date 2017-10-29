require 'test_helper'

class JobTest < ActiveSupport::TestCase

  test 'process' do
    attachment = build(:attachment)
    attachment.expects(:process).with.once
    Attachs::ProcessJob.perform_now attachment
  end

end
