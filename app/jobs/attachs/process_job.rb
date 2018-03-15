module Attachs
  class ProcessJob < Attachs::ApplicationJob

    def perform(attachment)
      attachment.process
    end

  end
end
