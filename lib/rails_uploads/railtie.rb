module RailsUploads
  class Railtie < Rails::Railtie

    config.uploads = ActiveSupport::OrderedOptions.new
    config.uploads.presets = {}
    config.uploads.default_presets = []
    config.uploads.base_url = ''

    initializer 'rails_uploads' do
      ::ActiveRecord::Base.send :extend, RailsUploads::ActiveRecord::Base::NonAttachable
    end

  end
end
