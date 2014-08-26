module Attachs
  module Storages
    class Base

      def initialize(attachment)
        @attachment = attachment
        @paths = {}
      end

      protected

      attr_reader :attachment

      def resize(*args)
        Attachs::Tools::Magick.resize(*args)
      end

      def path(style=nil)
        @paths[style ||= :original] ||= begin
          if attachment.exists?
            (attachment.options[:path] || Attachs.config.default_path).dup
          else
            attachment.options[:default_path].dup
          end.tap do |path|
            path.scan(/:([a-zA-Z0-9_]+)/).flatten.uniq.map(&:to_sym).each do |name|
              path.gsub! ":#{name}", interpolate(name, style).to_s
            end
            path.squeeze! '/'
            path.slice! 0 if path[0] == '/'
          end
        end
      end

      def interpolate(name, style)
        if interpolation = Attachs.config.interpolations[name]
          interpolation.call attachment, style
        else
          case name
          when :filename,:size,:basename,:extension
            attachment.send name
          when :type
            attachment.content_type.split('/').first
          when :timestamp
            (attachment.updated_at.to_f * 10000000000).to_i
          when :class
            attachment.record.class.name
          when :id
            attachment.record.id
          when :param
            attachment.record.to_param
          when :style
            style
          end
        end
      end

    end
  end
end
