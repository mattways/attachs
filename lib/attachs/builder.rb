module Attachs
  class Builder

    attr_reader :model, :concern

    def initialize(model)
      @model = model
      @concern = Module.new do
        extend ActiveSupport::Concern
        include Concern
      end
    end

    def define(multiple, attribute, options={})
      define_association multiple, attribute
      define_normalizer multiple, attribute
      unless multiple
        override_reader attribute
      end
      model.include concern
      model.attachments[attribute] = options.merge(multiple: multiple)
    end

    private

    def define_normalizer(multiple, attribute)
      concern.class_eval do
        private
        define_method "normalize_#{attribute}" do |attachment|
          if attachment
            attachment.assign_attributes(
              record_attribute: attribute,
              record_type: self.class.name,
            )
          end
          attachment
        end
      end
    end

    def define_association(multiple, attribute)
      options = {
        class_name: 'Attachs::Attachment',
        foreign_type: :record_base,
        dependent: :nullify,
				autosave: true,
        as: :record,
        before_add: "normalize_#{attribute}".to_sym
      }
      if multiple
        relation = -> { where(record_attribute: attribute).order(position: :asc) }
        model.has_many attribute, relation, options
      else
        relation = -> { where(record_attribute: attribute) }
        model.has_one attribute, relation, options
      end
      model.accepts_nested_attributes_for attribute, allow_destroy: true
    end

    def override_reader(attribute)
      concern.class_eval do
        define_method attribute do
          super() || send("build_#{attribute}")
        end
      end
    end

  end
end
