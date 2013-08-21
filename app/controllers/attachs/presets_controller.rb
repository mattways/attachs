module Attachs
  class PresetsController < ActionController::Base

    def generate
      filename = "#{params[:image]}.#{params[:format]}"
      preset = params[:preset].gsub('-', '_').to_sym
      if Rails.application.config.attachs.presets.has_key? preset
        image = Attachs::Types::Image.new(filename)
        if image.exists? and !image.exists?(preset)
          image.generate_preset preset
          redirect_to image.url(params[:preset]), cb: Random.rand(100000)
        end
      end
    end

  end
end
