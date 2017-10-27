module Attachs
  module Processors
    class Image < Base

      def process(destination_path, geometry)
        size, suffix = geometry.scan(/([^!#]+)(!|#)?$/).flatten
        strategy = detect_strategy(suffix)
        new_width, new_height = size.split('x').map(&:to_i)
        resize new_width, new_height, strategy, destination_path
      end

      private

      def detect_strategy(suffix)
        case suffix
        when '#'
          :cover
        when '!'
          :force
        else
          :contain
        end
      end

      def resize(new_width, new_height, strategy, destination_path)
        options = [Attachs.configuration.convert_options]
        case strategy
        when :cover
          options << "-resize #{new_width}x#{new_height}^ -gravity center"
          options << "-crop #{new_width}x#{new_height}+0+0 +repage"
        when :force
          options << "-resize #{new_width}x#{new_height}\!"
        when :contain
          options << "-resize #{new_width}x#{new_height}"
        end
        Console.convert source_path, destination_path, options.join(' ')
      end

    end
  end
end
