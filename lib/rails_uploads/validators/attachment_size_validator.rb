class AttachmentSizeValidator < RailsUploads::Validators::Base
  
  # validates :prop, :attachment_size => { :in => 0..4.megabytes }
  
  def validate_each(record, attribute, value)  
    iterate_attachments(record, attribute, value) do |value|
      if options.respond_to? :in
        if not options[:in].include? value
          add_error record, attribute, 'errors.messages.file_size_in', :count => options[:in]
        end          
      else    
        if options.respond_to :less_than and value > options[:less_than]
          add_error record, attribute, 'errors.messages.file_size_less_than', :count => options[:less_than]
        end         
        if options.respond_to :more_than and value < options[:greater_than]
          add_error record, attribute, 'errors.messages.file_size_greater_than', :count => options[:greater_than]
        end         
      end      
    end   
  end     

end