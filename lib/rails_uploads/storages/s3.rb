module RailsUploads
  module Storages
    class S3
      
      cattr_accessor :config

      def initialize(default)
        config = self.class.config[default ? Rails.env : 'production']
        AWS.config access_key_id: config['access_key_id'], secret_access_key: config['secret_access_key']
        @bucket = AWS::S3.new.buckets[config['bucket']]
        @tmp = {}
      end

      def exists?(path)
        object(path).exists?
      end

      def size(path)
        object(path).content_length
      end

      def url(path)
        base_url = Rails.application.config.uploads.base_url
        base_url.present? ? ::File.join(base_url, path) : object(path).public_url(secure: false)
      end

      def store(upload, path)
        @bucket.objects.create(path, Pathname.new(upload.path)).acl = :public_read
      end
      
      def delete(path)
        object(path).delete
      end

      def magick(source, output, upload)
        if @tmp[source].blank?
          if upload.present?
            @tmp[source] = upload.path
          else
            tmp = Tempfile.open('s3', Rails.root.join('tmp')) do |file|
              object(source).read do |chunk|
                file.write(chunk)
              end
            end
            @tmp[source] = tmp.path
          end
        end
        tmp = Tempfile.new('s3', Rails.root.join('tmp'))
        yield RailsUploads::Magick::Image.new(@tmp[source], tmp.path)
        store tmp, output
      end

      protected

      def object(path)
        @bucket.objects[path]
      end

    end
  end
end
