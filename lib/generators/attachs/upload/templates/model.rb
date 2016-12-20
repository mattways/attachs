class Upload < ActiveRecord::Base

  has_attachment(
    :file,
    path: 'uploads/:id-:style.:extension',
    styles: ->(upload) {
      upload.model.attachments[upload.record_attribute.to_sym][:styles]
    }
  )

  validates_presence_of :record_type, :record_attribute
  validates_attachment_presence_of :file

  def model
    if record_type
      record_type.classify.constantize
    end
  end

end
