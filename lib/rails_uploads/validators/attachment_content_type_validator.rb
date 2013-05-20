class AttachmentContentTypeValidator < RailsUploads::Validators::Base
  
  def validate_each(record, attribute, value)
    if value.present? and not value.is_default?
      unless options[:in].include? value.extname.from(1)
        add_error record, attribute, 'errors.messages.attachment_content_type', types: options[:in].join(', ')
      end
    end
  end        
  
end
