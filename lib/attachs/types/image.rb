module Attachs
  module Types
    class Image < File

      def presets
        default_presets | parse_array_setting(options[:presets])
      end
      
      def store
        super { presets.each { |name| generate_preset name } if presets.any? }
      end

      def delete
        super { presets.each { |name| delete_preset name } if presets.any? }
      end

      def generate_preset(name)
        if settings = Rails.application.config.attachs.presets[name]
          storage.magick destination_path, destination_path(name), upload do |image|
            if settings.respond_to? :call
              settings.call image
            else
              image.send "resize_to_#{settings[:method] || 'fill'}", settings[:width], settings[:height]
            end
          end
        end
      end

      def delete_preset(name)
        storage.delete path(name) if exists?(name)
      end

      protected

      def parse_array_setting(value)
        case value
        when Symbol
          [value]
        when String
          [value.to_sym]
        when Array
          value
        else
          []
        end
      end

      def default_presets
        parse_array_setting Rails.application.config.attachs.default_presets
      end

      def store_path(*args)
        ::File.join 'images', (args[0] ? args[0].to_s.gsub('_', '-') : 'original')
      end
      
    end
  end
end
