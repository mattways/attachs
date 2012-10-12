module RailsUploads
  module Types
    class File
      
      def initialize(source, options={})       
        if source.class == ActionDispatch::Http::UploadedFile
          @file = source          
          @created = false
        elsif source.is_a? String
          @filename = source
          @created = true
        end
        @options = options
      end

      def exists?
        ::File.exists? realpath
      end

      def size
        exists? ? ::File.size(realpath) : 0
      end

      def extname
        @extname ||= ::File.extname(filename)
      end   
      
      def path
        @path ||= "/#{::File.join(Rails.application.config.uploads.path, filename)}"
      end
      
      def realpath
        @realpath ||= Rails.root.join('public', Rails.application.config.uploads.path, filename)
      end
      
      def filename
        @filename ||= "#{(Time.now.to_f * 10000000).to_i}#{::File.extname @file.original_filename}"
      end
      
      def create
        unless @created
          ::File.open(realpath, 'wb') do |file|
            file.write(@file.read)
          end
          yield if block_given?
          @created = true
        end
      end      
      
      def delete
        ::File.delete realpath if exists?
      end
       
    end
  end 
end