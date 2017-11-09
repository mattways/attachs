module Attachs
  class Builder

    attr_reader :model, :concern

    def initialize(model, multiple)
      @model = model
      @multiple = multiple
      @concern = Module.new do
        extend ActiveSupport::Concern
        include Concern
      end
    end

    def define(attribute, options={})
      define_association attribute
      unless multiple?
        override_accessors attribute
      end
      model.include concern
      model.attachments[attribute] = options
    end

    def multiple?
      @multiple == true
    end

    private

    def define_association(attribute)
      options = {
        class_name: 'Attachs::Attachment',
        foreign_type: :record_base,
        dependent: :nullify,
        as: :record
      }
      if multiple?
        model.has_many(
          attribute,
          -> { where(record_attribute: attribute).order(position: :asc) },
          options.merge(
            after_add: ->(record, attachment) {
              attachment.record_type = record.class.name
              attachment.record_attribute = attribute
            }
          )
        )
      else
        model.has_one(
          attribute,
          -> { where(record_attribute: attribute) },
          options
        )
      end
      #model.accepts_nested_attributes_for attribute, update_only: false, allow_destroy: true
    end

    def override_accessors(attribute)
      concern.class_eval do
        define_method "#{attribute}=" do |value|
          if value.is_a?(Numeric) || value.is_a?(String)
            attachment = super(Attachs::Attachment.find(value))
          else
            attachment = super
          end
          attachment.record_type = self.class.name
          attachment.record_attribute = attribute
          attachment
        end
        %W(create_#{attribute} build_#{attribute}).each do |name|
          define_method name do |attributes={}|
            attachment = super(attributes)
            attachment.record_type = self.class.name
            attachment.record_attribute = attribute
            attachment
          end
        end
        define_method attribute do
          super() || send("build_#{attribute}")
        end
      end
    end

  end
end
