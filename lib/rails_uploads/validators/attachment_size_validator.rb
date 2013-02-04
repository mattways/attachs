class AttachmentSizeValidator < RailsUploads::Validators::Base
  
  # validates :prop, :attachment_size => { :in => 0..4.megabytes }
  
  def validate_each(record, attribute, value)
    if !has_default?(record, attribute) and value 
      if options.has_key? :in
        unless options[:in].include? value.size
          add_error record, attribute, 'attachment_size_in', :greater_than => options[:in].begin, :less_than => options[:in].end
        end          
      else    
        if options.has_key? :less_than and value.size > options[:less_than]
          add_error record, attribute, 'attachment_size_less_than', :less_than => options[:less_than]
        end         
        if options.has_key? :greater_than and value.size < options[:greater_than]
          add_error record, attribute, 'attachment_size_greater_than', :greater_than => options[:greater_than]
        end         
      end      
    end
  end

  protected

  def add_error(record, attribute, type, options)
    super(record, attribute, "errors.messages.#{type}", options)
  end

end
