module Attachs
  module Storages
    class S3 < Base

      def url(path)
        base_url = Attachs.configuration.base_url
        if base_url.present?
          Pathname.new(base_url).join(path).to_s
        else
          bucket.object(path).public_url
        end
      end

      def process(file, paths, options)
        if processable?(file.path)
          processor = build_processor(file.path)
          paths.each do |style, path|
            tmp = build_tempfile(path)
            processor.process tmp.path, options[style]
            upload tmp.path, path
          end
        else
          upload file.path, paths[:original]
        end
      end

      def get(path)
        file = build_tempfile(path)
        file.binmode
        bucket.object(path).get do |chunk|
          file.write chunk
        end
        file.rewind
        file.close
        file
      end

      def copy(current_path, new_path)
        Rails.logger.info "Copying: #{current_path} => #{new_path}"
        bucket.object(current_path).copy_to bucket.object(new_path), acl: 'public-read'
      end

      def move(current_path, new_path)
        Rails.logger.info "Moving: #{current_path} => #{new_path}"
        bucket.object(current_path).move_to bucket.object(new_path)
      end

      def delete(path)
        Rails.logger.info "Deleting: #{path}"
        bucket.object(path).delete
      end

      def exist?(path)
        bucket.object(path).exists?
      end

      def find_each
        bucket.objects.each do |object|
          yield object.key
        end
      end

      private

      def bucket
        @bucket ||= begin
          require 'aws-sdk'
          credentials = Aws::Credentials.new(
            Rails.application.secrets.aws_access_key_id,
            Rails.application.secrets.aws_secret_access_key
          )
          Aws.config.update(
            region: Attachs.configuration.region,
            credentials: credentials
          )
          Aws::S3::Resource.new.bucket Attachs.configuration.bucket
        end
      end

      def build_tempfile(path)
        extension = File.extname(path)
        Tempfile.new ['s3', extension]
      end

      def upload(local_path, remote_path)
        Rails.logger.info "Uploading: #{local_path} => #{remote_path}"
        bucket.object(remote_path).upload_file(
          local_path,
          acl: 'public-read',
          content_type: detect_content_type(remote_path),
          cache_control: 'max-age=315360000, public',
          expires: Time.parse('31 Dec 2037 23:55:55 GMT').httpdate
        )
      end

    end
  end
end
