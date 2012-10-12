module RailsUploads
  module Types
    class Image < File
      
      def path(preset=nil)
        preset_path super(), preset
      end
      
      def realpath(preset=nil)
        preset_path super(), preset        
      end      
      
      def create
        super() do
          if options[:presets]
            image = Magick::Image.read(realpath).first
            options[:presets].each do |name, settings|
              case settings[:method]
              when :fit
                thumbnail = image.resize_to_fit(settings[:width], settings[:height])
              else
                thumbnail = image.crop_resized(settings[:width], settings[:height])                          
              end
              thumbnail.write realpath(name)
            end   
          end       
        end
      end
      
      protected
      
      def preset_path(path, preset)
        preset and options[:presets][preset] ? path.sub('.', "-#{preset}.") : path         
      end
      
    end
  end
end