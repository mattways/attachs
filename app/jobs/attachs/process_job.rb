module Attachs
  class ProcessJob < ApplicationJob

    def perform(attachment)
      attachment.process
    end

  end
end
