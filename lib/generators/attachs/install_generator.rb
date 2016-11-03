require 'rails/generators'

module Attachs
  class InstallGenerator < Rails::Generators::Base

    source_root File.expand_path('../templates', __FILE__)

    def create_initializer_file
      copy_file 'initializer.rb', 'config/initializers/attachs.rb'
    end

  end
end
