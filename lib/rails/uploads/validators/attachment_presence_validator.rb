class AttachmentPresenceValidator < Rails::Uploads::Validators::Base
  
  # validates :prop, :attachment_presence => true
  
  def validate_each(record, attribute, value)
    if !has_default?(record, attribute) and not (value.kind_of? Rails::Uploads::Types::File and value.exists?)
      add_error record, attribute, 'errors.messages.attachment_presence'       
    end      
  end  

end
