module Attachs
  class AttachmentsController < Attachs::ApplicationController

    before_action :set_attachment, except: :create

    def create
      @attachment = Attachment.create
    end

    def upload
      if params[:chunk]
        @attachment.store(
          params[:chunk],
          if Rails.env.production?
            request.headers['HTTP_X_FILE']
          else
            case request.body
            when StringIO
              tmp = Tempfile.new
              tmp.write request.body
              tmp.path
            when Tempfile
              request.body.path
            end
          end
        )
      else
        @attachment.join
      end
    end

    def show
      if path = @attachment.ensure_style(params[:hash], params[:format])
        expires_in 1.year.from_now.httpdate, public: true
        send_file path, type: @attachment.content_type, disposition: :inline
      else
        raise ActionController::RoutingError.new('Not Found')
      end
    end

    private

    def set_attachment
      @attachment = Attachment.find(params[:id])
    end

  end
end
