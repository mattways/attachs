module Attachs
  class Storage

    def url(path)
      base_url = configuration.base_url
      if base_url.present?
        Pathname.new(base_url).join(path).to_s
      else
        bucket.object(path).public_url
      end
    end

    def process(local_path, remote_paths, content_type, options)
      processor = build_processor(local_path, content_type)
      if processor
        remote_paths.each do |style, path|
          file = build_tempfile
          processor.process file.path, options[style]
          upload file.path, path, content_type
        end
      else
        upload local_path, remote_paths[:original], content_type
      end
    end

    def generate_signed_policy(begins_at, key)
      rules = {
        expiration: (begins_at + configuration.expiration_policy).utc.iso8601,
        conditions: [
          { bucket: configuration.bucket },
          ['key', key],
          { acl: 'private' },
          ['Content-Type', 'application/octet-stream'],
          ['content-length-range', 0, configuration.maximum_size_policy]
        ]
      }
      policy = Base64.encode64(rules.to_json).tr("\n", '')
      digest = OpenSSL::HMAC.digest(OpenSSL::Digest.new('sha1'), configuration.secret_access_key, policy)
      signature = Base64.encode64(digest).tr "\n", ''
      [policy, signature]
    end

    def fetch(path)
      file = build_tempfile
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
      bucket.object(current_path).copy_to bucket.object(new_path)
    end

    def move(current_path, new_path)
      Rails.logger.info "Moving: #{current_path} => #{new_path}"
      bucket.object(current_path).move_to bucket.object(new_path)
    end

    def delete(path)
      Rails.logger.info "Deleting: #{path}"
      bucket.object(path).delete
    end

    def upload(local_path, remote_path, content_type)
      Rails.logger.info "Uploading: #{local_path} => #{remote_path}"
      bucket.object(remote_path).upload_file(
        local_path,
        content_type: content_type,
        cache_control: configuration.cache_control_header,
        expires: configuration.expires_header
      )
    end

    def delete_all
      find_each do |path|
        delete path
      end
    end

    def exists?(path)
      bucket.object(path).exists?
    end

    def find_each
      bucket.objects.each do |object|
        yield object.key
      end
    end

    private

    def configuration
      Attachs.configuration
    end

    def bucket
      @bucket ||= begin
        credentials = Aws::Credentials.new(
          configuration.access_key_id,
          configuration.secret_access_key
        )
        Aws.config.update(
          region: configuration.region,
          credentials: credentials
        )
        Aws::S3::Resource.new.bucket configuration.bucket
      end
    end

    def build_tempfile
      Tempfile.new 's3'
    end

    def build_processor(path, content_type)
      case content_type
      when /^image\//
        Processors::Image.new path
      end
    end

  end
end
