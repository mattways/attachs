class AttachmentContentTypeValidator < RailsUploads::Validators::Base
  
  # validates :prop, :attachment_content_type => { :in => ['png', 'gif'] }
  
  def validate_each(record, attribute, value)  
    if value and not options.has_key? :default
      unless options[:in].include? value.extname.from(1)
        add_error record, attribute, 'errors.messages.attachment_content_type', :types => options[:in].join(', ')
      end
    end
  end        
  
end
