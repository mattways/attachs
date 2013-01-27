module RailsUploads
  module Types
    class File
      
      def initialize(source, options={})
        if source.is_a? ActionDispatch::Http::UploadedFile or source.is_a? Rack::Test::UploadedFile
          @file = source          
          @stored = false
          @default = false
        elsif source.is_a? String
          @filename = source
          @stored = true
          @default = false
        elsif options.has_key? :default
          @filename = options[:default]
          @stored = true
          @default = true
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
        @path ||= ::File.join('', public_path)
      end
      
      def realpath
        return nil if @deleted
        @stored ? destination_path : @file.path
      end
      
      def filename
        return nil if @deleted
        @filename ||= "#{(Time.now.to_f * 10000000).to_i}#{::File.extname @file.original_filename}".downcase
      end
      
      def store
        if not @stored and @file
          ::File.open(destination_path, 'wb') do |file|
            file.write(@file.read)
          end
          @stored = true
          yield if block_given?
        end
      end      
      
      def delete
        if not @default and @stored and exists?
          ::File.delete realpath
          yield if block_given?
          @stored = false
          @deleted = true
        end
      end
       
      protected

      def destination_path
        Rails.root.join('public', public_path)
      end

      def public_path
        @default ? @options[:default] : ::File.join(Rails.application.config.uploads.path, filename)
      end

    end
  end 
end
