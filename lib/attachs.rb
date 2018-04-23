require 'open3'
require 'mime/types'
require 'attachs/extensions/action_view/base'
require 'attachs/extensions/active_record/validations/attachment_validator'
require 'attachs/extensions/active_record/validations/attachment_content_type_validator'
require 'attachs/extensions/active_record/validations/attachment_size_validator'
require 'attachs/extensions/active_record/base'
require 'attachs/processors/base'
require 'attachs/processors/image'
require 'attachs/builder'
require 'attachs/callbacks'
require 'attachs/concern'
require 'attachs/configuration'
require 'attachs/console'
require 'attachs/engine'
require 'attachs/errors'
require 'attachs/interpolations'
require 'attachs/railtie'
require 'attachs/storage'
require 'attachs/version'

module Attachs
  class << self

    delegate :clear, :reprocess, :fix_missings, to: :Attachment

    def configure
      yield configuration
    end

    def storage
      @storage ||= Storage.new
    end

    def configuration
      @configuration ||= Configuration.new
    end

  end
end
