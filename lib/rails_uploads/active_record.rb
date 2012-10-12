module RailsUploads
  module ActiveRecord
    module NonAttachableMethods
  
      def self.extended(base)
        ['image'].each do |type|
          base.send(:define_singleton_method, "attached_#{type}") do |*args|
            has_file *args.append(:type => type)             
          end
          base.send(:define_singleton_method, "attached_#{type.pluralize}") do |*args|
            has_files *args.append(:type => type)             
          end                    
        end       
      end

      def has_attachments?
        not defined?(@attachments).nil?
      end    

      def attached_file(*args)                    
        define_attachment *args.append(:multiple => false)
      end
      
      def attached_files(*args)
        define_attachment *args.append(:multiple => true)
      end
      
      protected
      
      def define_attachment(*args)
        options = args.extract_options!

        unless has_attachments?
          send :include, RailsUploads::ActiveRecord::AttachableMethods
          before_validation :create_attachments
          before_destroy :delete_attachments          
          before_save :mark_changed_attachments
          after_save :remove_deleted_attachments
          after_rollback :remove_added_attachments          
          @attachments = {}
        end
          
        define_method("#{args[0]}=") do |value|     
          if value
            a = get_attachments(value, args[0].to_sym, options, false)
            super(a ? (options[:multiple] ? a.map{|i|i.filename}.join(',') : a.filename) : nil)
          end
        end          
        define_method("#{args[0]}") do
          return (options[:multiple] ? [] : super()) unless super()
          get_attachments super(), args[0].to_sym, options, true
        end           

        @attachments[args[0].to_sym] = options       
      end
      
    end    
    module AttachableMethods

      protected
      
      def get_attachments(value, name, options, read)
        if value.is_a? ActionDispatch::Http::UploadedFile or value.is_a? String or value.is_a? Array or value.is_a? Hash
          @attachments = {} unless defined? @attachments
          return @attachments[name] if read and @attachments.has_key? name
          klass = attachment_class(options)
          if options[:multiple]
            @attachments[name] = [] unless @attachments[name].is_a? Array
            if value.is_a? Hash
              delete = []              
              attachments = attributes[name.to_s].nil? ? [] : attributes[name.to_s].split(',')
              value.each do |index, attachment|
                if index =~ /^[0-9]+$/ and attachments[index.to_i]
                  if attachment.has_key? '_destroy' and ['1', 'true'].include? attachment['_destroy']
                    delete << attachments[index.to_i] 
                  elsif attachment.has_key? 'file' 
                    attachments[index.to_i] = attachment['file']
                  end                  
                elsif attachment.has_key? 'file'
                  attachments << attachment['file']
                end            
              end
              if delete.any?
                attachments.delete_if { |a| delete.include?(a) }
              end
              value = attachments
            end   
            if value.is_a? Array or value.is_a? String
              (value.is_a?(Array) ? value : value.split(',')).each do |source|
                @attachments[name] << RailsUploads::Types.const_get(klass).new(source, options)                
              end
            end            
          else
            @attachments[name] = RailsUploads::Types.const_get(klass).new(value, options)            
          end     
          return @attachments[name]
        end      
      end
      
      def attachment_class(options)
        options.respond_to?(:type) ? options[:type].classify : 'File'
      end
      
      def mark_changed_attachments
        @added_attachments = []
        @deleted_attachments = []
        self.class.instance_variable_get('@attachments').each do |attribute, options|
          klass = attachment_class(options)
          if changed_attributes.has_key? attribute.to_s
            old_value = changed_attributes[attribute.to_s].nil? ? [] : changed_attributes[attribute.to_s].split(',')
            new_value = attributes[attribute.to_s].nil? ? [] : attributes[attribute.to_s].split(',')
            (old_value - new_value).each do |value|
              attachment = RailsUploads::Types.const_get(klass).new(value, options) 
              (new_value.include?(value) ? @added_attachments : @deleted_attachments) << attachment
            end
          end
        end
      end
      
      def iterate_attachments
        self.class.instance_variable_get('@attachments').each do |attribute, options|
          next unless value = send(attribute)
          if options[:multiple]
            value.each {|v| yield v if v} if value.is_a? Array
          else
            yield value
          end
        end        
      end
      
      def create_attachments
        iterate_attachments {|a| a.create}
      end

      def delete_attachments
        iterate_attachments {|a| a.delete}        
      end
      
      def remove_added_attachments
        @added_attachments.each {|a| a.delete}
      end
   
      def remove_deleted_attachments
        @deleted_attachments.each {|a| a.delete}
      end   
   
    end
  end
end

ActiveRecord::Base.send :extend, RailsUploads::ActiveRecord::NonAttachableMethods
