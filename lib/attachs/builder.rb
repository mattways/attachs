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
      define_normalizer attribute
      unless multiple
        override_accessors attribute
      end
      model.include concern
      model.attachments[attribute] = options.merge(multiple: multiple)
    end

    private

    def define_normalizer(attribute)
      concern.class_eval do
        private
        define_method "normalize_#{attribute}" do |attachment|
          if attachment
            attachment.assign_attributes(
              record_attribute: attribute,
              record_type: self.class.name
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
        as: :record
      }
      if multiple
        model.has_many(
          attribute,
          -> { where(record_attribute: attribute).order(position: :asc) },
          options.merge(after_add: :"normalize_#{attribute}")
        )
      else
        model.has_one(
          attribute,
          -> { where(record_attribute: attribute) },
          options
        )
      end
      model.accepts_nested_attributes_for attribute, allow_destroy: true
    end

    def override_accessors(attribute)
      concern.class_eval do
        define_method "#{attribute}=" do |value|
          send "normalize_#{attribute}", super(value)
        end
        define_method "#{attribute}_id=" do |value|
          send(
            "#{attribute}=", 
            if value.present?
              Attachment.find(value)
            end
          )
        end
        define_method "#{attribute}_id" do
          send(attribute).try :id
        end
        %W(create_#{attribute} build_#{attribute}).each do |name|
          define_method name do |attributes={}|
            send "normalize_#{attribute}", super(attributes)
          end
        end
        define_method attribute do
          super() || send("build_#{attribute}")
        end
      end
    end

  end
end
