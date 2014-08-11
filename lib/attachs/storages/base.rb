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
          path = (attachment.options[:path] || Attachs.config.default_path).dup
          path.scan(/:([a-zA-Z0-9_]+)/).flatten.uniq.map(&:to_sym).each do |name|
            if interpolation = Attachs.config.interpolations[name]
              value = interpolation.call(attachment)
            else
              case name
              when :filename,:size,:basename,:extension
                value = attachment.send(name)
              when :type
                value = attachment.content_type.split('/').first
              when :timestamp
                value = (attachment.updated_at.to_f * 10000000000).to_i
              when :class
                value = attachment.record.class.name
              when :id
                value = attachment.record.id
              when :param
                value = attachment.record.to_param
              when :style
                value = style
              else
                value = nil
              end
            end
            path.gsub! ":#{name}", value.to_s
          end
          if path[0] == '/'
            path.slice! 0
          end
          Pathname.new(path).to_s.squeeze('/')
        end
      end

    end
  end
end
