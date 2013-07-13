class AttachmentPresenceValidator < RailsUploads::Validators::Base
  
  def validate_each(record, attribute, value)
    unless value.present? and value.exists? and not value.is_default?
      add_error record, attribute, 'errors.messages.attachment_presence'
    end
  end  

end
