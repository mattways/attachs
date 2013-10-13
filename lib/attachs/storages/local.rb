module Attachs
  module Storages
    class Local

      def initialize(default)
        @tmp = (Rails.env.test? and !default)
      end

      def exists?(path)
        ::File.exists? realpath(path)
      end

      def size(path)
        ::File.size realpath(path)
      end
      
      def realpath(path)
        base_path.join path
      end

      def url(path)
        ::File.join Rails.application.config.attachs.base_url, path
      end

      def store(upload, path)
        create_dir realpath(path)
        upload.rewind # Hack to avoid empty files
        ::File.open(realpath(path), 'wb') do |file|
          while chunk = upload.read(16 * 1024)
            file.write(chunk)
          end
        end
      end
      
      def delete(path)
        ::File.delete realpath(path)
      end

      def magick(source, output, upload)
        create_dir realpath(output)
        yield Attachs::Magick::Image.new(realpath(source), realpath(output))
      end

      protected

      def tmp?
        @tmp == true
      end

      def base_path
        Rails.root.join tmp? ? 'tmp' : 'public'
      end

      def create_dir(path)
        dir = base_path.join('uploads', path).dirname
        FileUtils.mkdir_p dir unless ::File.directory? dir
      end

    end
  end
end
