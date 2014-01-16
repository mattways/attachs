class AttachmentPresenceValidator < Attachs::Validators::Base
  
  def validate_each(record, attribute, value)
    unless value.present? and value.exists? and !value.default?
      add_error record, attribute, 'attachment_presence'
    end
  end  

end
