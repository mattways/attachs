module Attachs
  class AttachmentsController < Attachs::ApplicationController

    def create
      @attachment = Attachment.create!(attachment_params)
    end

    def show
      @attachment = Attachment.unattached.find(params[:id])
    end

    private

    def attachment_params
      params.require(:attachment).permit(:record_type, :record_attribute, :upload)
    end

  end
end
