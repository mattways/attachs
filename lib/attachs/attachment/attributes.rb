module Attachs
  class Attachment
    module Attributes
      extend ActiveSupport::Concern

      attr_reader :record, :record_attribute, :attributes, :original_attributes, :options, :value, :source

      def initialize(record, record_attribute, options={}, attributes={})
        @record = record
        @record_attribute = record_attribute
        @options = options
        @original_attributes = @attributes = attributes.deep_symbolize_keys
      end

      %i(id size filename content_type uploaded_at).each do |name|
        define_method name do
          attributes[name]
        end
      end

      def basename
        if filename
          File.basename filename, extension
        end
      end

      def extension
        if filename
          File.extname filename
        end
      end

      def present?
        filename.present? && content_type.present? && size.present?
      end

      def blank?
        !present?
      end

      def persisted?
        record.persisted? && paths.any? && uploaded_at
      end

      def changed?
        @original_attributes != @attributes
      end

      def type
        if content_type
          if content_type.starts_with?('image/')
            'image'
          else
            'file'
          end
        end
      end

      def position
        if options[:multiple]
          attributes[:position]
        end
      end

      def position=(value)
        if options[:multiple]
          attributes[:position] = value
          write_record
        end
      end

      def styles
        case value = options[:styles]
        when Proc
          value.call(record) || {}
        when Hash
          value
        else
          {}
        end
      end

      def paths
        attributes[:paths] ||= {}
      end

      def old_paths
        attributes[:old_paths] ||= []
      end

      def respond_to_missing?(name, include_private=false)
        attributes.has_key?(name) || super
      end

      def method_missing(name, *args, &block)
        if attributes.has_key?(name)
          attributes[name]
        else
          super
        end
      end

      private

      def write_record
        unless record.destroyed?
          record.send "#{record_attribute}_will_change!"
          record.send :write_attribute, record_attribute, raw_attributes
        end
      end

      def raw_attributes
        if options[:multiple]
          collection = record.send(:read_attribute, record_attribute).reject do |hash|
            hash['id'] == id
          end
          collection << attributes
        else
          attributes
        end
      end

    end
  end
end
