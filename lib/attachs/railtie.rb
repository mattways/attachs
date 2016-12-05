module Attachs
  class Railtie < Rails::Railtie

    initializer 'attachs.extensions' do
      ::ActiveRecord::Base.include(
        Attachs::Extensions::ActiveRecord::Base,
        Attachs::Extensions::ActiveRecord::Validations
      )
      ::ActiveRecord::ConnectionAdapters::TableDefinition.include(
        Attachs::Extensions::ActiveRecord::ConnectionAdapters::TableDefinition
      )
      ::ActiveRecord::ConnectionAdapters::AbstractAdapter.include(
        Attachs::Extensions::ActiveRecord::ConnectionAdapters::AbstractAdapter
      )
      ::ActiveRecord::Migration::CommandRecorder.include(
        Attachs::Extensions::ActiveRecord::Migration::CommandRecorder
      )
    end

    initializer 'attachs.locales' do
      I18n.load_path += Dir[File.expand_path('../locales/*.yml', __FILE__)]
    end

    rake_tasks do
      load 'tasks/attachs.rake'
    end

  end
end
