require 'test_helper'

class JobTest < ActiveSupport::TestCase

  test 'process' do
    attachment.expects(:process).with.once
    Attachs::ProcessJob.perform_now attachment
  end

  private

  def attachment
    @attachment ||= Attachs::Attachment.new
  end

end
