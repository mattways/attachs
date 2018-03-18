module Attachs
  class ProcessJob < Attachs::ApplicationJob

    def perform(path, attachment)
      attachment.process path
    end

  end
end
