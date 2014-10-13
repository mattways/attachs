module Attachs
  module Processors
    class Thumbnail < Base

      def initialize(attachment, source)
        super
        @width, @height = dimensions(source)
      end

      def process(style, destination)
        new_width, new_height, strategy, options = geometry(style)
        resize source, width, height, new_width, new_height, strategy, options, destination
      end

      protected

      attr_reader :width, :height

      def geometry(style)
        geometry = Attachs.config.styles[style]
        width, height = geometry.scan(/[^x]+/).map(&:to_i)
        case geometry[/!|#/]
        when '#'
          strategy = 'cover'
        when '!'
          strategy = 'force'
        else
          strategy = 'contain'
        end
        options = Attachs.config.convert_options[style]
        [width, height, strategy, options]
      end

      def resize(source, width, height, new_width, new_height, strategy, custom_options, destination)
        case strategy
        when 'cover'
          ratio = [new_width.to_f/width, new_height.to_f/height].max
          options = "-resize #{(ratio*width).ceil}x#{(ratio*height).ceil} -gravity center -crop #{new_width}x#{new_height}+0+0"
        when 'force'
          options = "-resize #{new_width}x#{new_height}\!"
        when 'contain'
          options = "-resize #{new_width}x#{new_height}"
        end
        if global_options = Attachs.config.global_convert_options
          options << " #{global_options}"
        end
        if custom_options
          options << " #{custom_options}"
        end
        convert source, options, destination
      end

      def dimensions(source)
        if output = identify(source, '-format %wx%h')
          output.split('x').map(&:to_i)
        end
      end

      def convert(source, options, destination)
        run "convert '#{source}' #{options} '#{destination}'"
      end

      def identify(source, options)
        run "identify #{options} '#{source}'"
      end

    end
  end
end
