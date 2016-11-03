module Attachs
  module Extensions
    module ActiveRecord
      module Base
        extend ActiveSupport::Concern

        module ClassMethods

          def has_attachment(attribute, options={})
            raise 'Path required' unless options.has_key?(:path)
            include Attachs::Concern
            attachments[attribute] = options
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
            define_method "#{attribute}=" do |value|
              send(attribute).assign value
            end
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

          def has_attachments(attribute, options={})
            has_attachment attribute, options.merge(multiple: true)
          end

        end
      end
    end
  end
end
