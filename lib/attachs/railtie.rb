module Attachs
  class Railtie < Rails::Railtie

    config.attachs = ActiveSupport::OrderedOptions.new
    config.attachs.presets = {}
    config.attachs.default_presets = []
    config.attachs.default_validations = {}
    config.attachs.base_url = ''
    config.attachs.storage = :local

    initializer 'attachs' do
      ::ActiveRecord::Base.send :include, Attachs::ActiveRecord::Base
      if config.attachs.storage == :s3
        require 'aws-sdk' 
        Attachs::Storages::S3.config = YAML.load_file(Rails.root.join('config', 's3.yml'))
      end
    end

  end
end
