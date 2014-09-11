module Attachs
  module Tools
    module Magick
      class << self

        def dimensions(source)
          if output = run("identify -format %wx%h '#{source}'")
            output.split('x').map(&:to_i)
          end
        end

        def resize(source, style, destination=nil)
          size = Attachs.config.styles[style]
          new_width, new_height = size.scan(/[^x]+/).map(&:to_i)
          case strategy = size[/!|#/]
          when '#'
            width, height = dimensions(source)
            ratio = [new_width.to_f/width, new_height.to_f/height].max
            options = "-resize #{(ratio*width).ceil}x#{(ratio*height).ceil} -gravity center -crop #{new_width}x#{new_height}+0+0"
          when '!'
            options = "-resize #{new_width}x#{new_height}\!"
          else
            options = "-resize #{new_width}x#{new_height}"
          end
          if global_options = Attachs.config.global_convert_options
            options << " #{global_options}"
          end
          if style_options = Attachs.config.convert_options[style]
            options << " #{style_options}"
          end
          if destination
            run "convert '#{source}' #{options} '#{destination}'"
          else
            run "mogrify #{options} '#{source}'"
          end
        end

        protected

        def run(cmd)
          stdout, stderr, status = Open3.capture3(cmd)
          if status.success?
            stdout.strip
          else
            false
          end
        end

      end
    end
  end
end
