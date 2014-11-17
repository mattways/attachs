module Attachs
  module Storages
    class Local < Base

      def url(*args)
        if attachment.url?
          options = args.extract_options!
          style = (args[0] || :original)
          base_url.join(path(style)).to_s.tap do |url|
            if find_option(options, :cachebuster, Attachs.config.cachebuster)
              url << "?#{attachment.updated_at.to_i}"
            end
          end
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
          attachment.uploaded!
        end
        process_styles force
      end

      def process_styles(force=false)
        if attachment.image?
          attachment.processors.each do |klass|
            processor = klass.new(attachment, realpath)
            attachment.styles.each do |style|
              if force == true
                delete realpath(style)
              end
              unless File.exist? realpath(style)
                FileUtils.mkdir_p realpath(style).dirname
                processor.process style, realpath(style)
              end
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

      def delete(realpath)
        if File.exist? realpath
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
