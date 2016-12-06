require 'rails/generators'

module Attachs
  module Generators
    class UploadGenerator < ::Rails::Generators::Base
      include Rails::Generators::Migration

      source_root File.expand_path('../templates', __FILE__)

      def create_model_file
        copy_file 'model.rb', 'app/models/upload.rb'
      end

      def create_migration_file
        migration_template 'migration.rb', 'db/migrate/create_uploads.rb'
      end

      def self.next_migration_number(path)
        Time.now.utc.strftime '%Y%m%d%H%M%S'
      end

    end
  end
end
