module Attachs
  module Storages
    class Base

      def initialize(attachment)
        @attachment = attachment
      end

      protected

      attr_reader :attachment

      def template
        @template ||= begin
          if attachment.exists?
            (attachment.options[:path] || Attachs.config.default_path).dup
          else
            attachment.options[:default_path].dup
          end.tap do |path|
            path.scan(/:([a-zA-Z0-9_]+)/).flatten.uniq.map(&:to_sym).each do |name|
              if name != :style
                path.gsub! ":#{name}", interpolate(name)
              end
            end
            path.squeeze! '/'
            path.slice! 0 if path[0] == '/'
          end
        end
      end

      def path(style=:original)
        template.gsub(':style', style.to_s)
      end

      def interpolate(name)
        if interpolation = Attachs.config.interpolations[name]
          interpolation.call(attachment).to_s.parameterize
        else
          case name
          when :basename
            attachment.basename.parameterize
          when :filename
            "#{attachment.basename.parameterize}.#{attachment.extension}"
          when :size
            attachment.size
          when :extension
            attachment.extension
          when :type
            attachment.content_type.split('/').first.parameterize
          when :timestamp
            Rails.logger.info "#{attachment.record.inspect}"
            Rails.logger.info "#{attachment.inspect}"
            Rails.logger.info "Setting time #{(attachment.updated_at.to_f * 10000000000).to_i}"
            (attachment.updated_at.to_f * 10000000000).to_i
          when :class
            attachment.record.class.name.parameterize
          when :id
            attachment.record.id
          when :attribute
            attachment.attribute.to_s.parameterize
          end.to_s
        end
      end

    end
  end
end
