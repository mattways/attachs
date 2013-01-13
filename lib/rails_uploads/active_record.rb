module RailsUploads
  module ActiveRecord
    module NonAttachableMethods
  
      def self.extended(base)
        ['image'].each do |type|
          base.send(:define_singleton_method, "attached_#{type}") do |*args|
            attached_file *args.append(:type => type)             
          end
          base.send(:define_singleton_method, "attached_#{type.pluralize}") do |*args|
            attached_files *args.append(:type => type)             
          end                    
        end       
      end

      def attached_file(*args)
        options = args.extract_options!
        options[:multiple] = false                   
        define_attachment *args.append(options)
      end
      
      def attached_files(*args)
        options = args.extract_options!
        options[:multiple] = true
        define_attachment *args.append(options)
      end

      def is_attachable?
        not defined?(@attachments).nil?
      end          

      protected
      
      def define_attachment(*args)
        options = args.extract_options!
        make_attachable unless is_attachable?
        args.each do |attr|
          define_attachable_attribute_methods attr.to_sym, options
          @attachments[attr.to_sym] = options
        end
      end

      def make_attachable
        send :include, RailsUploads::ActiveRecord::AttachableMethods
        before_save :store_attachments, :check_changed_attachments
        after_save :remove_deleted_attachments
        before_destroy :delete_attachments           
        after_rollback :remove_stored_attachments 
        @attachments = {}
      end

      def define_attachable_attribute_methods(attr, options)
        ['set', 'get'].each do |method|
          send "define_attachable_attribute_method_#{method}", attr, options
        end
      end
      
      def define_attachable_attribute_method_set(attr, options)
        define_method "#{attr}=" do |value|
          @attachments = {} if defined?(@attachments).nil?
          if options[:multiple]
            if value.is_a? Hash
=begin
              currents = attributes[attr.to_s].nil? ? [] : attributes[atrr.to_s].split(',')
              delete = []              
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
=end
              if delete.any?
                attachments.delete_if { |a| delete.include?(a) }
              end
              value = attachments
            elsif value.is_a? Array
              @attachments[attr] = value.map { |value| get_attachment_instance(value, options) }
              super(@attachments[attr].map{|v|v.filename}.join(','))
            end
          elsif !options[:multiple] and (value.is_a? ActionDispatch::Http::UploadedFile or value.is_a? Rack::Test::UploadedFile)
            @attachments[attr] = get_attachment_instance(value, options)
            super(@attachments[attr].filename)
          end
        end 
      end

      def define_attachable_attribute_method_get(attr, options)
        define_method attr do
          @attachments = {} if defined?(@attachments).nil?
          return @attachments[attr] if @attachments.has_key? attr
          value = super()
          return (options[:multiple] ? [] : nil) unless value
          value = value.split(',')
          if value.length > 1
            @attachments[attr] = value.map { |value| get_attachment_instance(value, options) }
          else
            @attachments[attr] = get_attachment_instance(value[0], options)
          end
          @attachments[attr]
        end 
      end

    end    
    module AttachableMethods

      protected

      def get_attachment_instance(source, options)
        klass = options.respond_to?(:type) ? options[:type].classify : 'File'      
        RailsUploads::Types.const_get(klass).new(source, options)  
      end
      
      def check_changed_attachments
        @stored_attachments = []
        @deleted_attachments = []
        self.class.instance_variable_get('@attachments').each do |attr, options|
          if changed_attributes.has_key? attr.to_s
            old_value = changed_attributes[attr.to_s].nil? ? [] : changed_attributes[attr.to_s].split(',')
            new_value = attributes[attr.to_s].nil? ? [] : attributes[attr.to_s].split(',')
            (new_value - old_value).each do |value|
              @stored_attachments << get_attachment_instance(value, options)
            end
            (old_value - new_value).each do |value|
              @deleted_attachments << get_attachment_instance(value, options)
            end
          end
        end
      end
      
      def iterate_attachments
        self.class.instance_variable_get('@attachments').each do |attr, options|
          next unless value = send(attr)
          if options[:multiple]
            value.each { |v| yield v if v } 
          else
            yield value
          end
        end        
      end
      
      def store_attachments
        iterate_attachments { |a| a.store }
      end

      def delete_attachments
        iterate_attachments { |a| a.delete }  
      end
      
      def remove_stored_attachments
        @stored_attachments.each { |a| a.delete }
      end
   
      def remove_deleted_attachments
        @deleted_attachments.each { |a| a.delete }
      end   
   
    end
  end
end

ActiveRecord::Base.send :extend, RailsUploads::ActiveRecord::NonAttachableMethods
