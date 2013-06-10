class AttachmentSizeValidator < RailsUploads::Validators::Base
  include ActionView::Helpers::NumberHelper
    
  def validate_each(record, attribute, value)
    if value.present? and not value.is_default?
      if options.has_key? :in
        unless options[:in].include? value.size
          add_error record, attribute, 'attachment_size_in', min: number_to_human_size(options[:in].begin), max: number_to_human_size(options[:in].end)
        end          
      else    
        if options.has_key? :less_than and value.size > options[:less_than]
          add_error record, attribute, 'attachment_size_less_than', count: number_to_human_size(options[:less_than])
        end         
        if options.has_key? :greater_than and value.size < options[:greater_than]
          add_error record, attribute, 'attachment_size_greater_than', count: number_to_human_size(options[:greater_than])
        end         
      end      
    end
  end

  protected

  def add_error(record, attribute, type, options)
    super(record, attribute, "errors.messages.#{type}", options)
  end

end
