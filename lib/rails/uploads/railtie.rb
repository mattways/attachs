module Rails
  module Uploads
    class Railtie < Rails::Railtie

      config.uploads = ::ActiveSupport::OrderedOptions.new
      config.uploads.presets = {}
      config.uploads.default_presets = []
      config.uploads.base_url = ''

      initializer 'uploads.methods' do
        ::ActiveRecord::Base.send :extend, Rails::Uploads::ActiveRecord::NonAttachable
      end

    end
  end
end
