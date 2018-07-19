module Attachs
  class Storage

    def path(slug)
      expand_path(slug).to_s
    end

    def exists?(slug)
      File.exists? expand_path(slug)
    end

    def store(id, chunk, source_path)
      ensure_folder id
      destination_path = base_path.join(id).join(chunk) 
      move source_path, destination_path
    end

    def join(id, basename)
      folder_path = base_path.join(id)
      upload_path = folder_path.join('upload')
      pattern = folder_path.join('*')
      Dir[pattern].sort.each do |path|
        File.write upload_path, File.read(path), mode: 'a'
        delete path
      end
      size = File.size(upload_path)
      content_type = Console.content_type(upload_path)
      extension = MIME::Types[content_type].first.extensions.first
      destination_path = folder_path.join("#{basename}.#{extension}") 
      move upload_path, destination_path
      [size, content_type, extension, destination_path]
    end

    def process(source_slug, destination_slug, content_type, options)
      source_path = expand_path(source_slug)
      destination_path = expand_path(destination_slug)
      processor = build_processor(source_path, content_type)
      processor.process destination_path, options
      fix_permissions_and_ownership destination_path
      destination_path.to_s
    end

    def destroy(slug)
      delete expand_path(slug)
    end

    def clear
      find_each do |path|
        delete path
      end
    end

    private

    delegate :configuration, to: :Attachs

    def base_path
      Rails.root.join 'storage'
    end

    def expand_path(slug)
      base_path.join slug
    end

    def ensure_folder(id)
      FileUtils.mkdir_p base_path.join(id)
    end

    def move(current_path, new_path)
      Rails.logger.info "Moving: #{current_path} => #{new_path}"
      FileUtils.mv current_path, new_path
    end

    def delete(path)
      Rails.logger.info "Deleting: #{path}"
      FileUtils.rm path
    end

    def fix_permissions_and_ownership(path)
      File.chown nil, Process.gid, path
      File.chmod 0644, path
    end

    def find_each
      Dir[base_path.join('*').join('**')].each do |path|
        yield path
      end
    end

    def build_processor(path, content_type)
      case content_type
      when /^image\//
        Processors::Image.new path
      end
    end

  end
end
