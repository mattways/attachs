require 'rails/generators'

module Attachs
  module Generators
    class InstallGenerator < Rails::Generators::Base
      include Rails::Generators::Migration

      source_root File.expand_path('../templates', __FILE__)

      def create_initializer_file
        copy_file 'initializer.rb', 'config/initializers/attachs.rb'
      end

      def create_migration_file
        migration_template 'migration.rb', 'db/migrate/create_attachments.rb'
      end

      def self.next_migration_number(path)
        Time.now.utc.strftime '%Y%m%d%H%M%S'
      end

    end
  end
end
