module Attachs
  class Builder

    attr_reader :model, :concern

    def initialize(model)
      @model = model
      @concern = Module.new
    end

    def define(attribute, options={})
      unless options.has_key?(:path)
        raise 'Path required'
      end
      model.include Attachs::Concern
      model.attachments[attribute] = options
      define_writer attribute
      define_reader attribute, options
      define_attributes_writer attribute, options
      model.include concern
    end

    private

    def define_writer(attribute)
      concern.class_eval do
        define_method "#{attribute}=" do |value|
          send(attribute).assign value
        end
      end
    end

    def define_reader(attribute, options)
      concern.class_eval do
        define_method attribute do
          variable = "@#{attribute}"
          if instance = instance_variable_get(variable)
            instance
          else
            if options[:multiple] == true
              klass = Attachs::Collection
            else
              klass = Attachs::Attachment
            end
            instance_variable_set(
              variable,
              klass.new(self, attribute, options, super())
            )
          end
        end
      end
    end

    def define_attributes_writer(attribute, options)
      concern.class_eval do
        define_method "#{attribute}_attributes=" do |collection_or_attributes|
          if options[:multiple] == true
            collection_or_attributes.each do |attributes|
              if id = attributes.delete(:id)
                attachment = send(attribute).find(id)
              else
                attachment = send(attribute).new
              end
              attributes.each do |name, value|
                attachment.send "#{name}=", value
              end
            end
          else
            collection_or_attributes.each do |name, value|
              send(attribute).send "#{name}=", value
            end
          end
        end
      end
    end

  end
end
