require 'tuning'
require 'open3'
require 'aws-sdk-s3'
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
require 'attachs/interpolations'
require 'attachs/railtie'
require 'attachs/storage'
require 'attachs/version'

module Attachs
  class << self

    def configure
      yield configuration
    end

    def storage
      @storage ||= Storage.new
    end

    def configuration
      @configuration ||= Configuration.new
    end

    %i(clear reprocess fix_missings).each do |name|
      define_method name do |*args|
        Attachs::Attachment.send name, *args
      end
    end

  end
end
