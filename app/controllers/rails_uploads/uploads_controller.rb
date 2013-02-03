module RailsUploads
  class UploadsController < ApplicationController

    def generate_image_preset
      image = RailsUploads::Types::Image.new("#{params[:image]}.#{params[:format]}")
      image.send :generate_preset, params[:preset].to_sym
      redirect_to request.url, :cb => Random.rand(100000)
    end

  end
end
