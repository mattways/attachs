module Attachs
  module Types
    class File
      
      def initialize(source, options={})
        @options = options
        @deleted = false        
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
      end
      
      def private?
        @options and @options[:private] == true
      end

      def default?
        @default == true
      end
      
      def stored?
        @stored == true
      end

      def deleted?
        @deleted == true
      end

      def exists?(*args)
        return false if deleted?
        storage.exists? path(*args)
      end

      def size(*args)
        return 0 if deleted?
        storage.size path(*args)
      end

      def extname
        return nil if deleted?
        @extname ||= ::File.extname(filename)
      end   

      def filename
        return nil if deleted?
        @filename ||= "#{(Time.now.to_f * 10000000).to_i}#{::File.extname upload.original_filename}".downcase
      end      

      def original_filename
        return nil unless upload.present?
        upload.original_filename
      end

      def path(*args)
        return nil if deleted?
        stored? ? destination_path(*args) : upload.path.to_s
      end

      def realpath(*args)
        return nil if deleted? or storage_type == :s3
        stored? ? storage.realpath(path(*args)) : upload.path.to_s
      end

      def url(*args)
        return nil if deleted? or !stored?
        storage.url path(*args)
      end

      def store
        if !stored? and upload?
          @storage = build_storage
          storage.store upload, destination_path
          yield if block_given?
          @stored = true
          @deleted = false
        end
      end
      
      def delete
        if !default? and stored? and exists?
          storage.delete path
          yield if block_given?
          @storage = build_storage(:local) if upload?
          @stored = false
          @deleted = true
        end
      end
       
      protected

      attr_reader :upload, :storage, :options

      def storage_type
        Rails.application.config.attachs.storage
      end

      def build_storage(type=nil)
        klass = (type || storage_type).to_s.classify 
        Attachs::Storages.const_get(klass).new default?, private?
      end

      def upload?
        upload.present?
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
