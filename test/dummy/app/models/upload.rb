class Upload < ActiveRecord::Base

  has_attachment(
    :file,
    path: ':id-:style.:extension',
    styles: ->(record) {
      record.model.attachments[record.record_attribute.to_sym][:styles]
    }
  )

  validates_presence_of :file, :record_type, :record_attribute

  def model
    if record_type
      record_type.classify.constantize
    end
  end

end
