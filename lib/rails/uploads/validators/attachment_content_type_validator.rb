class AttachmentContentTypeValidator < Rails::Uploads::Validators::Base
  
  # validates :prop, :attachment_content_type => { :in => ['png', 'gif'] }
  
  def validate_each(record, attribute, value)  
    if !has_default?(record, attribute) and value
      unless options[:in].include? value.extname.from(1)
        add_error record, attribute, 'errors.messages.attachment_content_type', :types => options[:in].join(', ')
      end
    end
  end        
  
end
