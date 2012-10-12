class AttachmentContentTypeValidator < RailsUploads::Validators::Base
  
  # validates :prop, :attachment_content_type => { :in => ['png', 'gif'] }
  
  def validate_each(record, attribute, value)  
    iterate_attachments(record, attribute, value) do |value|    
      unless options[:in].include? value.extname.from(1)
        add_error record, attribute, 'errors.messages.file_content_type', :types => options[:in]          
      end
    end
  end        
  
end
