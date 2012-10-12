module RailsUploads
  class Railtie < Rails::Railtie

    config.uploads = ActiveSupport::OrderedOptions.new
    config.uploads.path = 'uploads'

  end
end
