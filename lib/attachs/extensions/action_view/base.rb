module Attachs
  module Extensions
    module ActionView
      module Base
        extend ActiveSupport::Concern

        def image_tag(source, options={})
          if source.is_a?(Attachment)
            attachment = source
            style = options.delete(:style)
            source = attachment.url(style)
            unless options.has_key?(:alt)
              options[:alt] = attachment.description
            end
          end
          super
        end

      end
    end
  end
end
