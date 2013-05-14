module RailsUploads
  class PresetsController < ApplicationController

    layout false

    def generate
      filename = "#{params[:image]}.#{params[:format]}"
      preset = params[:preset].gsub('-', '_').to_sym
      if Rails.application.config.uploads.presets.has_key?(preset)
        image = RailsUploads::Types::Image.new(filename)
        if image.exists? and !image.exists?(preset)
          image.send :generate_preset, preset
          redirect_to request.url, :cb => Random.rand(100000) and return
        end
      end
    end

  end
end
