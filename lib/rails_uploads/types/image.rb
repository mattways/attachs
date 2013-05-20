module RailsUploads
  module Types
    class Image < File

      def presets
        Rails.application.config.uploads.default_presets | (@options[:presets] or [])
      end
      
      def store
        super { presets.each { |name| generate_preset name } if presets.any? }
      end

      def delete
        super { presets.each { |name| storage.delete path(name) if exists?(name) } if presets.any? }
      end

      def generate_preset(name)
        storage.magick destination_path, destination_path(name), @upload do |image|
          settings = Rails.application.config.uploads.presets[name]
          if settings.is_a? Proc
            settings.call image
          else
            case settings[:method]
            when :fit
              image.resize_to_fit settings[:width], settings[:height]
            else
              image.resize_to_fill settings[:width], settings[:height]                        
            end
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
