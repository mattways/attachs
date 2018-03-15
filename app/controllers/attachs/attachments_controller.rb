module Attachs
  class AttachmentsController < Attachs::ApplicationController

    def create
      @attachment = Attachment.create(attachment_params)
      @policy, @signature = generate_signed_policy(@attachment)
    end

    def queue
      @attachment = Attachment.uploading.find(params[:id])
      @attachment.processing!
      ProcessJob.perform_later @attachment
    end

    def show
      @attachment = Attachment.uploaded.find(params[:id])
    end

    private

    def attachment_params
      params.require(:attachment).permit(
        :record_type,
        :record_attribute
      )
    end

    def generate_signed_policy(attachment)
      Attachs.storage.generate_signed_policy attachment.requested_at, attachment.key
    end

  end
end
