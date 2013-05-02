module RailsUploads
  module Types
    class Image < File

      def has_presets?
        presets.any?
      end

      def presets
        Rails.application.config.uploads.default_presets | (@options[:presets] or [])
      end
      
      def store
        super() do
          if has_presets?
            presets.each do |name|
              generate_preset name
            end   
          end       
        end
      end

      def delete
        super() do
          if has_presets?
            presets.each do |name|
              ::File.delete realpath(name) if exists? name
            end
          end
        end
      end
      
      protected

      def generate_preset(name)
        check_store_dir(name)
        image = RailsUploads::Magick::Image.new(realpath, realpath(name))
        settings = Rails.application.config.uploads.presets[name]
        if settings.is_a? Proc
          thumbnail = settings.call(image)
        else
          case settings[:method]
          when :fit
            thumbnail = image.resize_to_fit(settings[:width], settings[:height])
          else
            thumbnail = image.resize_to_fill(settings[:width], settings[:height])                          
          end
        end
      end

      def store_path(*args)
        ::File.join('images', (args[0] ? args[0].to_s.gsub('_', '-') : 'original'))
      end
      
    end
  end
end
