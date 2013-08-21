module Attachs
  module Storages
    class S3
      
      cattr_accessor :config

      def initialize(default)
        if (Rails.env.test? and !default)
          env = 'test'
        elsif default
          env = 'production'
        else
          env = Rails.env
        end
        config = self.class.config[env]
        AWS.config access_key_id: config['access_key_id'], secret_access_key: config['secret_access_key']
        @bucket = AWS::S3.new.buckets[config['bucket']]
      end

      def exists?(path)
        object(path).exists?
      end

      def size(path)
        object(path).content_length
      end

      def url(path)
        base_url = Rails.application.config.attachs.base_url
        base_url.present? ? ::File.join(base_url, path) : object(path).public_url(secure: false)
      end

      def store(upload, path)
        bucket.objects.create(path, Pathname.new(upload.path)).acl = :public_read
      end
      
      def delete(path)
        object(path).delete
      end

      def magick(source, output, upload)
        if cache[source].blank?
          if upload.present?
            cache[source] = upload.path
          else
            remote = create_tmp_file
            remote.binmode
            object(source).read { |chunk| remote.write(chunk) }
            remote.close
            remote.open
            cache[source] = remote.path
          end
        end
        tmp = create_tmp_file
        yield Attachs::Magick::Image.new(cache[source], tmp.path)
        store tmp, output
      end

      protected

      attr_reader :bucket
      
      def create_tmp_file
        Tempfile.new('s3')
      end

      def cache
        @cache ||= {}
      end

      def object(path)
        bucket.objects[path]
      end

    end
  end
end
