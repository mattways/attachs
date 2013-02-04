module RailsUploads
  class UploadsController < ApplicationController

    def generate_image_preset
      filename = "#{params[:image]}.#{params[:format]}"
      preset = params[:preset].gsub('-', '-').to_sym
      if ::File.exists?(Rails.root.join('public', 'uploads', 'images', 'original', filename)) and Rails.application.config.uploads.presets.has_key?(preset)
        RailsUploads::Types::Image.new(filename).send :generate_preset, preset
        redirect_to request.url, :cb => Random.rand(100000)
      end
    end

  end
end
