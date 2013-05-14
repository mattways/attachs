module RailsUploads
  module Types
    class File
      
      def initialize(source, options={})
        if source.is_a? ActionDispatch::Http::UploadedFile or source.is_a? Rack::Test::UploadedFile
          @upload = source          
          @stored = false
          @default = false
        elsif source.is_a? String
          @upload = false
          @filename = source
          @stored = true
          @default = false
        elsif options.has_key? :default
          @upload = false
          @filename = options[:default]
          @stored = true
          @default = true
        end
        @deleted = false        
        @options = options
      end

      def is_default?
        @default
      end

      def is_upload?
        @upload != false
      end

      def is_stored?
        @stored
      end

      def is_deleted?
        @deleted
      end 

      def exists?(*args)
        return false if is_deleted?
        ::File.exists? realpath(*args)
      end

      def size(*args)
        return 0 if is_deleted?
        ::File.size realpath(*args)
      end

      def extname
        return nil if is_deleted?
        @extname ||= ::File.extname(filename)
      end   

      def filename
        return nil if is_deleted?
        @filename ||= "#{(Time.now.to_f * 10000000).to_i}#{::File.extname @upload.original_filename}".downcase
      end      

      def path(*args)
        return nil if is_deleted?
        ::File.join '', public_path(*args)
      end

      def url(*args)
        return nil if is_deleted?
        ::File.join Rails.application.config.uploads.base_url, path(*args)
      end
      
      def realpath(*args)
        return nil if is_deleted?
        ::File.expand_path(is_stored? ? destination_path(*args) : @upload.path)
      end

      def store
        if not is_stored? and is_upload?
          create_dir
          @upload.rewind # Hack to avoid empty files
          ::File.open(destination_path, 'wb') do |file|
            while chunk = @upload.read(16 * 1024)
              file.write(chunk)
            end
          end
          @stored = true
          yield if block_given?
        end
      end
      
      def delete
        if not is_default? and is_stored? and exists?
          ::File.delete realpath
          yield if block_given?
          @stored = false
          @deleted = true
        end
      end
       
      protected

      def base_path
        Rails.root.join (Rails.env == 'test' and not is_default?) ? 'tmp' : 'public'
      end

      def create_dir(*args)
        dir = base_path.join('uploads', store_path(*args))
        FileUtils.mkdir_p dir unless ::File.directory? dir
      end

      def destination_path(*args)
        base_path.join public_path(*args)
      end

      def public_path(*args)
        ::File.join 'uploads', store_path(*args), filename
      end

      def store_path(*args)
        'files'
      end

    end
  end
end
