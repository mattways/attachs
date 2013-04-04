module Rails
  module Uploads
    class PresetsController < ApplicationController

      def generate
        filename = "#{params[:image]}.#{params[:format]}"
        preset = params[:preset].gsub('-', '_').to_sym
        if ::File.exists?(Rails.root.join('public', 'uploads', 'images', 'original', filename)) and Rails.application.config.uploads.presets.has_key?(preset)
          Rails::Uploads::Types::Image.new(filename).send :generate_preset, preset
          redirect_to request.url, :cb => Random.rand(100000)
        end
      end

    end
  end
end
