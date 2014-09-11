module Attachs
  module Storages
    class S3 < Base

      def url(*args)
        if attachment.public? and attachment.processed?
          options = args.extract_options!
          style = args[0]
          if Attachs.config.base_url.present?
            Pathname.new(Attachs.config.base_url, path(style)).to_s
          else
            object(style).public_url(secure: secure?).to_s
          end
        end
      end

      def process(force=false)
        if attachment.upload?
          stream attachment.upload, path
        end
        process_styles force
      end

      def process_styles(force=false)
        if attachment.image?
          unless cache[path]
            download = Tempfile.new('s3')
            object.read do |chunk|
              download.write chunk
            end
            cache[path] = download
          end
          attachment.styles.each do |style|
            if force == true
              object(style).delete
            end
            unless object(style).exists?
              tmp = Tempfile.new('s3')
              resize cache[path].path, style, tmp.path
              stream tmp, path(style)
            end
          end
        end
      end

      def destroy
        object.delete
        destroy_styles
      end

      def destroy_styles
        if attachment.image?
          attachment.styles.each do |style|
            object(style).delete
          end
        end
      end

      protected

      def secure?
        if !options[:ssl].nil?
          options[:ssl]
        else
          Attachs.config.s3[:ssl]
        end
      end

      def move(origin, destination)
        bucket.objects[origin].move_to(destination)
      end

      def cache
        @cache ||= {}
      end

      def bucket
        @bucket ||= AWS::S3.new.buckets[Attachs.config.s3[:bucket]]
      end

      def object(style=:original)
        bucket.objects[path(style)]
      end

      def stream(file, path)
        object = bucket.objects.create(path, File.open(file.path, 'rb'))
        if attachment.private?
          object.acl = :private
        else
          object.acl = :public_read
        end
        cache[path] = file
      end

    end
  end
end
