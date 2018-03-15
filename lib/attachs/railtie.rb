module Attachs
  class Railtie < Rails::Railtie

    initializer 'attachs.action_view' do
      ActiveSupport.on_load :action_view do
        ::ActionView::Base.include(
          Extensions::ActionView::Base
        )
      end
    end

    initializer 'attachs.active_record' do
      ActiveSupport.on_load :active_record do
        ::ActiveRecord::Base.include(
          Extensions::ActiveRecord::Base,
          Extensions::ActiveRecord::Validations
        )
      end
    end

    initializer 'attachs.i18n' do
      I18n.load_path += Dir[File.expand_path('../../locales/*.yml', __FILE__)]
    end

    rake_tasks do
      load 'tasks/attachs.rake'
    end

  end
end
