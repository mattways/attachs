class AttachmentPresenceValidator < RailsUploads::Validators::Base
  
  # validates :prop, :attachment_presence => true
  
  def validate_each(record, attribute, value)
    unless value.kind_of? RailsUploads::Types::File and value.exists? 
      add_error record, attribute, 'errors.messages.attachment_presence'       
    end      
  end  

end
