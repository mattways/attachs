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
            @options[:presets].each do |name, settings|
              image = RailsUploads::Magick::Image.new(realpath, realpath(name))
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
        (preset and @options[:presets][preset]) ? path.to_s.reverse.sub('.', "-#{preset.to_s.gsub('_', '-')}.".reverse).reverse : path         
      end
      
    end
  end
end
