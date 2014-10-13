module Attachs
  module Task
    def self.process(force)
      model = (ENV['class'] || ENV['CLASS']).classify.constantize
      attachment = (ENV['attachment'] || ENV['ATTACHMENT']).to_sym
      model.find_each do |record|
        model.attachments.each do |attr, options|
          if attr == attachment
            record.send(attr).process(force)
          end
        end
      end
    end
  end
end

namespace :attachs do
  namespace :refresh do
    desc 'Refreshs all styles.'
    task all: :environment do
      Attachs::Task.process true
      Rails.logger.info 'All styles regenerated successfully.'
    end
    desc 'Refreshs missing styles.'
    task missing: :environment do
      Attachs::Task.process false
      Rails.logger.info 'Missing styles regenerated successfully.'
    end
  end
end
