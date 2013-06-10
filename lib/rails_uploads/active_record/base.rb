module RailsUploads
  module ActiveRecord
    module Base

      def self.included(base)
        base.extend ClassMethods
      end

      protected

      def build_attachment_instance(source, options)
        klass = options.has_key?(:type) ? options[:type].to_s.classify : 'File'
        RailsUploads::Types.const_get(klass).new(source, options)  
      end
      
      def check_changed_attachments
        @stored_attachments = []
        @deleted_attachments = []
        self.class.attachments.each do |attr, options|
          if @attributes[attr.to_s].present? and send("delete_#{attr}") == '1'
            send "#{attr}_will_change!"
            @attributes[attr.to_s] = nil
          end
          if changed_attributes.has_key? attr.to_s
            stored = attributes[attr.to_s]
            deleted = changed_attributes[attr.to_s]
            add_changed_attachment stored, options, :stored if stored.present?
            add_changed_attachment deleted, options, :deleted if deleted.present?
          end
        end
      end
      
      def iterate_attachments
        self.class.attachments.each do |attr, options|
          next unless instance = send(attr)
          yield instance
        end
      end
      
      def add_changed_attachment(source, options, type)
        (type == :stored ? @stored_attachments : @deleted_attachments) << (source.is_a?(String) ? build_attachment_instance(source, options) : source)
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

      module ClassMethods

        attr_reader :attachments
    
        def self.extended(base)
          [:image].each do |type|
            base.send(:define_singleton_method, "attached_#{type}") do |*args|
              options = args.extract_options!
              options[:type] = type
              attached_file *args.append(options)
            end
          end
        end

        def attached_file(*args)
          options = args.extract_options!
          options.reverse_merge! type: :file
          define_attachment *args.append(options)
        end

        def inherited(subclass)
          subclass.instance_variable_set(:@attachments, @attachments)
          super
        end

        def is_attachable?
          attachments.present?
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
            if value.is_a? ActionDispatch::Http::UploadedFile or value.is_a? Rack::Test::UploadedFile or (value.is_a? String and value =~ /^[a-zA-Z0-9_-]+\.[a-zA-z]+$/)
              @attachments[attr] = build_attachment_instance(value, options)
              super(@attachments[attr].filename)
            end
          end
          attr_accessor "delete_#{attr}".to_sym
        end

        def define_attachable_attribute_method_get(attr, options)
          define_method attr do
            @attachments = {} if defined?(@attachments).nil?
            return @attachments[attr] if @attachments.has_key? attr
            return nil if super().nil? and not options.has_key? :default
            @attachments[attr] = build_attachment_instance(super(), options)
          end 
        end

      end    
    end
  end
end
