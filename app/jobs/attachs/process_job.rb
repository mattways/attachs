module Attachs
  class ProcessJob < ActiveJob::Base
    queue_as :default

    def perform(attachment)
      attachment.process
    end

  end
end
