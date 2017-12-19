module Attachs
  class AttachmentsController < ApplicationController

    def create
      @attachment = Attachs::Attachment.create(attachment_params)
      @policy, @signature = generate_signed_policy(@attachment)
    end

    def queue
      @attachment = Attachs::Attachment.uploading.find(params[:id])
      @attachment.processing!
      ProcessJob.perform_later @attachment
    end

    def show
      @attachment = Attachs::Attachment.uploaded.find(params[:id])
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
