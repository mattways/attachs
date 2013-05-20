module RailsUploads
  class PresetsController < ApplicationController

    def generate
      filename = "#{params[:image]}.#{params[:format]}"
      preset = params[:preset].gsub('-', '_').to_sym
      if Rails.application.config.uploads.presets.has_key? preset
        image = RailsUploads::Types::Image.new(filename)
        if image.exists? and !image.exists?(preset)
          image.send :generate_preset, preset
          redirect_to image.url(params[:preset]).to_s, :cb => Random.rand(100000)
        end
      end
    end

  end
end
