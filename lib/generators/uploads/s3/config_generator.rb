module Uploads
  module S3
    class ConfigGenerator < Rails::Generators::Base
      
      source_root File.expand_path('../templates', __FILE__)

      def install
        copy_file 's3.yml', 'config/s3.yml'
      end

    end
  end
end
