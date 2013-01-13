module RailsUploads
  module Types
    class Image < File
      
      def exists?(preset=nil)
        @deleted ? false : ::File.exists?(realpath(preset)) 
      end
     
      def size(preset=nil)
        return 0 if @deleted
        (exists?(preset) ? ::File.size(realpath(preset)) : 0)
      end
 
      def path(preset=nil)
        preset_path super(), preset
      end
      
      def realpath(preset=nil)
        preset_path super(), preset        
      end      
      
      def store
        super() do
          if @options[:presets]
            image = ::Magick::Image.read(realpath).first
            @options[:presets].each do |name, settings|
              if settings.is_a? Proc
                thumbnail = settings.call
              else
                case settings[:method]
                when :fit
                  thumbnail = image.resize_to_fit(settings[:width], settings[:height])
                else
                  thumbnail = image.crop_resized(settings[:width], settings[:height])                          
                end
              end
              thumbnail.write realpath(name)
            end   
          end       
        end
      end

      def delete
        super() do
          @options[:presets].each do |name, settings|
            ::File.delete realpath(name) if exists? name
          end
        end
      end
      
      protected
      
      def preset_path(path, preset)
        (preset and @options[:presets][preset]) ? path.sub('.', "-#{preset}.") : path         
      end
      
    end
  end
end
