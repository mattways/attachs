module RailsUploads
  class Railtie < Rails::Railtie

    config.uploads = ActiveSupport::OrderedOptions.new
    config.uploads.presets = {}
    config.uploads.default_presets = []
    config.uploads.default_validations = {}
    config.uploads.base_url = ''
    config.uploads.storage = :local

    initializer 'rails_uploads' do
      ::ActiveRecord::Base.send :include, RailsUploads::ActiveRecord::Base
      if config.uploads.storage == :s3
        require 'aws-sdk' 
        RailsUploads::Storages::S3.config = YAML.load_file(Rails.root.join('config', 's3.yml'))
      end
    end

  end
end
