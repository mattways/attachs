module Attachs
  module ActiveRecord
    module Base
      extend ActiveSupport::Concern

      protected

      def attachments
        @attachments ||= begin
          {}.tap do |value|
            self.class.attachments.each do |attr, options|
              value[attr] = Attachs::Attachment.new(self, attr, options)
            end
          end
        end
      end

      def queued_attachments
        @queued_attachments ||= { process: {}, destroy: {} }
      end

      def queue_attachment(attr, options, value)
        unless queued_attachments[:destroy].has_key? attr
          queued_attachments[:destroy][attr] = attachments[attr]
        end
        attachment = Attachs::Attachment.new(self, attr, options, value)
        queued_attachments[:process][attr], attachments[attr] = attachment
      end

      def commit_attachments
        self.class.attachments.each do |attr, options|
          instance_variable_set "@destroy_#{attr}", nil
        end
        queued_attachments[:destroy].each do |attr, attachment|
          attachment.destroy
        end
        queued_attachments[:process].each do |attr, attachment|
          attachment.process
        end
        queued_attachments[:destroy] = {}
        queued_attachments[:process] = {}
      end

      def destroy_attachments
        self.class.attachments.each do |attr, options|
          send(attr).destroy
        end
      end

      module ClassMethods

        def has_attached_file(*args)
          options = args.extract_options!
          unless attachable?
            make_attachable
          end
          args.each do |attr|
            define_attachment_methods attr, options
            attachments[attr] = options
          end
        end

        def attachments
          @attachments ||= {}
        end

        def attachable?
          attachments.any?
        end

        def inherited(subclass)
          subclass.instance_variable_set :@attachments, @attachments
          super
        end

        protected

        def make_attachable
          after_save :commit_attachments
          after_destroy :destroy_attachments
        end

        def define_attachment_methods(attr, options)
          define_method "#{attr}=" do |value|
            attachments[attr] = queue_attachment(attr, options, value)
          end
          define_method attr do
            attachments[attr]
          end
          attr_reader "destroy_#{attr}"
          define_method "destroy_#{attr}=" do |value|
            instance_variable_set "@destroy_#{attr}", value
            if [1, '1', true].include? value
              send "#{attr}=", nil
            end
          end
        end

      end
    end
  end
end
