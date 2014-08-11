module Attachs
  class Railtie < Rails::Railtie

    initializer 'attachs' do
      ::ActiveRecord::Base.send(
        :include,
        Attachs::ActiveRecord::Base,
        Attachs::ActiveRecord::Validators
      )
      ::ActiveRecord::ConnectionAdapters::TableDefinition.send(
        :include,
        Attachs::ActiveRecord::ConnectionAdapters::TableDefinition
      )
      ::ActiveRecord::ConnectionAdapters::AbstractAdapter.send(
        :include,
        Attachs::ActiveRecord::ConnectionAdapters::AbstractAdapter
      )
      ::ActiveRecord::Migration::CommandRecorder.send(
        :include,
        Attachs::ActiveRecord::Migration::CommandRecorder
      )
      I18n.load_path += Dir[File.expand_path('../locales/*.yml', __FILE__)]
    end

    rake_tasks do
      load 'tasks/attachs.rake'
    end

    config.after_initialize do
      if Attachs.config.s3[:access_key_id] and Attachs.config.s3[:secret_access_key]
        require 'aws-sdk'
        AWS.config(
          access_key_id: Attachs.config.s3[:access_key_id],
          secret_access_key: Attachs.config.s3[:secret_access_key]
        )
      end
    end

  end
end
