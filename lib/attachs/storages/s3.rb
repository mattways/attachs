module Attachs
  module Storages
    class S3 < Base

      def url(*args)
        if attachment.url?
          options = args.extract_options!
          style = (args[0] || :original)
          if Attachs.config.base_url.present?
            Pathname.new(Attachs.config.base_url).join(path(style)).to_s
          else
            object(style).public_url(secure: find_option(options, :ssl, Attachs.config.s3[:ssl])).to_s
          end.tap do |url|
            if find_option(options, :cachebuster, Attachs.config.cachebuster)
              url << "?#{attachment.updated_at.to_i}"
            end
          end
        end
      end

      def process(force=false)
        if attachment.upload?
          stream attachment.upload, path
          attachment.uploaded!
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
          attachment.processors.each do |klass|
            processor = klass.new(attachment, cache[path].path)
            attachment.styles.each do |style|
              if force == true
                object(style).delete
              end
              unless object(style).exists?
                tmp = Tempfile.new('s3')
                processor.process style, tmp.path
                stream tmp, path(style)
              end
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
