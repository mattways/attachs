module RailsUploads
  module Schema
    
    def attachment(*args)
      options = args.extract_options!
      options.reverse_merge :multiple => false
      column args[0], (options[:multiple] ? :text : :string)
    end
    
    def attachments(*args)
      options = args.extract_options!
      attachment *(args | [options.reverse_merge(:multiple => :true)])
    end  
   
  end
end

ActiveRecord::ConnectionAdapters::TableDefinition.send :include, RailsUploads::Schema
