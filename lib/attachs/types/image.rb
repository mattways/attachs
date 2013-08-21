module Attachs
  module Types
    class Image < File

      def presets
        Rails.application.config.attachs.default_presets | (options[:presets] || [])
      end
      
      def store
        super { presets.each { |name| generate_preset name } if presets.any? }
      end

      def delete
        super { presets.each { |name| storage.delete path(name) if exists?(name) } if presets.any? }
      end

      def generate_preset(name)
        storage.magick destination_path, destination_path(name), upload do |image|
          settings = Rails.application.config.attachs.presets[name]
          if settings.respond_to? :call
            settings.call image
          else
            image.send "resize_to_#{settings[:method] || 'fill'}", settings[:width], settings[:height]
          end
        end
      end

      def delete_preset(name)
        storage.delete path(name)
      end

      protected

      def store_path(*args)
        ::File.join('images', (args[0] ? args[0].to_s.gsub('_', '-') : 'original'))
      end
      
    end
  end
end
