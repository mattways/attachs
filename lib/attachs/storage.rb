module Attachs
  class Storage

    def url(slug)
      Pathname.new(Attachs.configuration.base_url || '/').join('files').join(slug).to_s
    end

    def path(slug)
      base_path.join(slug).to_s
    end

    def process(id, source_path, slug, content_type, options)
      ensure_folder id
      destination_path = path(slug)
      if options
        processor = build_processor(source_path, content_type)
        processor.process destination_path, options
      else
        move source_path, destination_path
      end
      fix_permissions_and_ownership destination_path
    end

    def destroy(slug)
      delete path(slug)
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

    def ensure_folder(id)
      FileUtils.mkdir_p base_path.join(id)
    end

    def move(current_path, new_path)
      Rails.logger.info "Moving: #{current_path} => #{new_path}"
      FileUtils.mv current_path, new_path
    end

    def remove(path)
      Rails.logger.info "Deleting: #{path}"
      FileUtils.rm path
    end

    def fix_permissions_and_ownership(path)
      File.chown nil, Process.gid, path
      File.chmod 0644, path
    end

    def find_each
      Dir[base_path.join('*/**')].each do |path|
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
