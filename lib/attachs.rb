require 'open3'
require 'attachs/attachment'
require 'attachs/processors/base'
require 'attachs/processors/thumbnail'
require 'attachs/storages/base'
require 'attachs/storages/local'
require 'attachs/storages/s3'
require 'attachs/types/base'
require 'attachs/types/default'
require 'attachs/types/regular'
require 'attachs/active_record/base'
require 'attachs/active_record/connection_adapters'
require 'attachs/active_record/migration'
require 'attachs/active_record/validators'
require 'attachs/active_record/validators/attachment_content_type_validator'
require 'attachs/active_record/validators/attachment_presence_validator'
require 'attachs/active_record/validators/attachment_size_validator'
require 'attachs/railtie'

module Attachs
  class << self

    def configure
      yield config
    end

    def config
      @config ||= begin
        ActiveSupport::OrderedOptions.new.tap do |config|
          config.s3 = { ssl: false }
          config.base_url = ''
          config.styles = {}
          config.cachebuster = true
          config.interpolations = {}
          config.convert_options = {}
          config.global_styles = []
          config.global_convert_options= ''
          config.default_storage = :local
          config.default_processors = [:thumbnail]
          config.default_path = '/:timestamp-:filename'
        end
      end
    end

  end
end
