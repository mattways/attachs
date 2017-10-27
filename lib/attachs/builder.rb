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
        override_setter attribute
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
    end

    def override_setter(attribute)
      concern.class_eval do
        define_method "#{attribute}=" do |value|
          attachment = super(value)
          attachment.record_attribute = attribute
          attachment
        end
      end
    end

  end
end
