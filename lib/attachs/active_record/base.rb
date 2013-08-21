module Attachs
  module ActiveRecord
    module Base
      extend ActiveSupport::Concern

      included do
        singleton_class.class_eval do
          [:file, :image].each do |type|
            name = :"has_attached_#{type}"
            define_method name do |*args|
              options = args.extract_options!
              options[:type] = type
              define_attachment *args.append(options)
            end
            alias_method :"attached_#{type}", name
          end
        end
      end

      protected

      attr_reader :stored_attachments, :deleted_attachments

      def attachments
        @attachments ||= {}
      end

      def build_attachment_instance(source, options)
        klass = options.has_key?(:type) ? options[:type].to_s.classify : 'File'
        Attachs::Types.const_get(klass).new source, options
      end
      
      def check_changed_attachments
        @stored_attachments = []
        @deleted_attachments = []
        self.class.attachments.each do |attr, options|
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
        (type == :stored ? stored_attachments : deleted_attachments) << (source.is_a?(String) ? build_attachment_instance(source, options) : source)
      end
      
      def store_attachments
        iterate_attachments { |a| a.store }
      end

      def delete_attachments
        iterate_attachments { |a| a.delete }  
      end
      
      def remove_stored_attachments
        stored_attachments.each { |a| a.delete }
      end
   
      def remove_deleted_attachments
        deleted_attachments.each { |a| a.delete }
      end   

      module ClassMethods

        attr_reader :attachments
    
        def inherited(subclass)
          subclass.instance_variable_set(:@attachments, @attachments)
          super
        end

        def attachable?
          attachments.present?
        end

        protected
        
        def define_attachment(*args)
          options = args.extract_options!
          make_attachable unless attachable?
          args.each do |attr|
            define_attachable_attribute_methods attr.to_sym, options
            define_default_validations attr.to_sym, options
            attachments[attr.to_sym] = options
          end
        end

        def make_attachable
          before_save :store_attachments, :check_changed_attachments
          after_save :remove_deleted_attachments
          before_destroy :delete_attachments           
          after_rollback :remove_stored_attachments 
          @attachments = {}
        end

        def define_default_validations(attr, options)
          default_validations = Rails.application.config.attachs.default_validations[options[:type]]
          validates attr, default_validations.dup if default_validations.present?
        end

        def define_attachable_attribute_methods(attr, options)
          ['set','get'].each { |method| send "define_attachable_attribute_method_#{method}", attr, options }
        end
        
        def define_attachable_attribute_method_set(attr, options)
          define_method "#{attr}=" do |value|
            if value.is_a? ActionDispatch::Http::UploadedFile or value.is_a? Rack::Test::UploadedFile or (value.is_a? String and value =~ /^[a-zA-Z0-9_-]+\.[a-zA-z]+$/)
              attachment = build_attachment_instance(value, options)
              attachments[attr] = attachment
              write_attribute attr, attachment.filename 
            end
          end
          define_method "delete_#{attr}=" do |value|
            if attribute_present? attr and value == '1'
              send "#{attr}_will_change!"
              attachments[attr] = nil
              attributes[attr.to_s] = nil
            end
            instance_variable_set("@delete_#{attr}".to_sym, value)
          end
        end

        def define_attachable_attribute_method_get(attr, options)
          define_method attr do
            return attachments[attr] if attachments.has_key? attr
            return nil if super().nil? and not options.has_key? :default
            attachments[attr] = build_attachment_instance(super(), options)
          end 
          attr_reader :"delete_#{attr}"
        end

      end    
    end
  end
end
