module Attachs
  module Storages
    class Local < Base

      def url(style=nil)
        if attachment.public? and attachment.processed?
          base_url.join(path(style)).to_s
        end
      end

      def process(force=false)
        if attachment.upload?
          FileUtils.mkdir_p realpath.dirname
          attachment.upload.rewind
          File.open(realpath, 'wb') do |file|
            while chunk = attachment.upload.read(16 * 1024)
              file.write chunk
            end
          end
        end
        process_styles force
      end

      def process_styles(force=false)
        if attachment.image?
          attachment.styles.each do |style|
            if force == true
              delete realpath(style)
            end
            unless File.file? realpath(style)
              FileUtils.mkdir_p realpath(style).dirname
              resize realpath, style, realpath(style)
            end
          end
        end
      end

      def destroy
        delete realpath
        destroy_styles
      end

      def destroy_styles
        if attachment.image?
          attachment.styles.each do |style|
            delete realpath(style)
          end
        end
      end

      protected

      def move(origin, destination)
        FileUtils.mv base_path.join(origin), base_path.join(destination)
      end

      def delete(realpath)
        if File.file? realpath
          File.delete realpath
        end
      end

      def realpath(style=:original)
        base_path.join(path(style))
      end

      def base_path
        @base_path ||= begin
          if attachment.private?
            Rails.root.join 'private'
          else
            Rails.root.join 'public'
          end
        end
      end

      def base_url
        @base_url ||= begin
          if Attachs.config.base_url.present?
            Pathname.new Attachs.config.base_url
          else
            Pathname.new '/'
          end
        end
      end

    end
  end
end
