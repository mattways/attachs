module Attachs
  class AttachmentsController < Attachs::ApplicationController

    def create
      @attachment = Attachment.create!(params[:blob])
    end

    def show
      @attachment = Attachment.find(params[:id])
      fresh_when @attachment, public: true
      send_file @attachment.location(params[:style]), disposition: :inline
    end

  end
end
