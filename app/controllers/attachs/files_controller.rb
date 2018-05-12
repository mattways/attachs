module Attachs
  class FilesController < Attachs::ApplicationController

    def create
      blob = params[:blob]
      Rails.logger.info request.headers.to_h.keys
      Rails.logger.info params
      Rails.logger.info request.headers['HTTP_X_FILE']
      @attachment = Attachment.create!(blob_path: blob.path)
    end

    def show
      @attachment = Attachment.find(params[:id])
      if style = @attachment.style(params[:hash])
        path = @attachment.path(style)
        if File.extname(path)[1..-1] == params[:format]
          unless File.exists?(path)
            @attachment.process style
          end
          expires_in 1.year.from_now.httpdate, public: true
          send_file path, type: @attachment.content_type, disposition: :inline
        else
          not_found
        end
      else
        not_found
      end
    end

    private

    def not_found
      raise ActionController::RoutingError.new('Not Found')
    end

  end
end
