module RailsUploads
  class Railtie < Rails::Railtie

    config.uploads = ::ActiveSupport::OrderedOptions.new
    config.uploads.presets = {}
    config.uploads.default_presets = []
    config.uploads.base_url = ''

  end
end
