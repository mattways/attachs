module RailsUploads
  module Types
    class File
      
      def initialize(source, options={})
        if source.is_a? ActionDispatch::Http::UploadedFile or source.is_a? Rack::Test::UploadedFile
          @upload = source          
          @stored = false
          @default = false
          @storage = build_storage(:local)
        elsif source.is_a? String
          @upload = false
          @filename = source
          @stored = true
          @default = false
          @storage = build_storage
        elsif options.has_key? :default
          @upload = false
          @filename = options[:default]
          @stored = true
          @default = true
          @storage = build_storage
        end
        @deleted = false        
        @options = options
      end

      def is_default?
        @default
      end
      
      def is_stored?
        @stored
      end

      def is_deleted?
        @deleted
      end

      def exists?(*args)
        return false if is_deleted?
        storage.exists? path(*args)
      end

      def size(*args)
        return 0 if is_deleted?
        storage.size path(*args)
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
        is_stored? ? destination_path(*args) : @upload.path
      end

      def url(*args)
        return nil if is_deleted? or not is_stored?
        storage.url path(*args)
      end

      def store
        if not is_stored? and is_upload?
          @storage = build_storage
          storage.store @upload, destination_path
          yield if block_given?
          @stored = true
          @deleted = false
        end
      end
      
      def delete
        if not is_default? and is_stored? and exists?
          storage.delete path
          yield if block_given?
          @storage = build_storage(:local) if @upload.present?
          @stored = false
          @deleted = true
        end
      end
       
      protected

      def build_storage(type=nil)
        type = (type or Rails.application.config.uploads.storage)
        RailsUploads::Storages.const_get(type.to_s.classify).new(is_default?)
      end

      def storage
        @storage
      end

      def is_upload?
        @upload != false
      end

      def destination_path(*args)
        ::File.join 'uploads', store_path(*args), filename
      end

      def store_path(*args)
        'files'
      end

    end
  end
end
