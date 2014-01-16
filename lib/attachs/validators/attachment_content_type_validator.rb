class AttachmentContentTypeValidator < Attachs::Validators::Base
  
  def validate_each(record, attribute, value)
    if value.present? and !value.default?
      if options[:in].exclude? value.extname.from(1)
        add_error record, attribute, 'attachment_content_type', types: options[:in].to_sentence
      end
    end
  end        
  
end
