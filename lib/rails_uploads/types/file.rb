module RailsUploads
  module Types
    class File
      
      def initialize(source, options={})       
        if source.is_a? ActionDispatch::Http::UploadedFile or source.is_a? Rack::Test::UploadedFile
          @file = source          
          @stored = false
        elsif source.is_a? String
          @filename = source
          @stored = true
        end
        @deleted = false        
        @options = options
      end

      def exists?
        @deleted ? false : ::File.exists?(realpath)
      end

      def size
        return 0 if @deleted
        @size ||= (exists? ? ::File.size(realpath) : 0)
      end

      def extname
        return nil if @deleted 
        @extname ||= ::File.extname(filename)
      end   
      
      def path
        return nil if @deleted
        @path ||= ::File.join('', Rails.application.config.uploads.path, filename)
      end
      
      def realpath
        return nil if @deleted
        @stored ? uploads_path : @file.path
      end
      
      def filename
        return nil if @deleted
        @filename ||= "#{(Time.now.to_f * 10000000).to_i}#{::File.extname @file.original_filename}".downcase
      end
      
      def store
        if not @stored and @file
          ::File.open(uploads_path, 'wb') do |file|
            file.write(@file.read)
          end
          @stored = true
          yield if block_given?
        end
      end      
      
      def delete
        if @stored and exists?
          ::File.delete realpath
          yield if block_given?
          @stored = false
          @deleted = true
        end
      end
       
      protected

      def uploads_path
        Rails.root.join('public', Rails.application.config.uploads.path, filename)
      end

    end
  end 
end
