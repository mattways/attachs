require 'attachs/extensions/active_record/validations/attachment_validator'
require 'attachs/extensions/active_record/validations/attachment_content_type_validator'
require 'attachs/extensions/active_record/validations/attachment_presence_validator'
require 'attachs/extensions/active_record/validations/attachment_size_validator'
require 'attachs/extensions/active_record/base'
require 'attachs/extensions/active_record/connection_adapters'
require 'attachs/extensions/active_record/migration'
require 'attachs/jobs/base'
require 'attachs/jobs/delete_job'
require 'attachs/jobs/update_job'
require 'attachs/processors/base'
require 'attachs/processors/image'
require 'attachs/storages/base'
require 'attachs/storages/s3'
require 'attachs/attachment'
require 'attachs/builder'
require 'attachs/collection'
require 'attachs/concern'
require 'attachs/configuration'
require 'attachs/console'
require 'attachs/railtie'
require 'attachs/version'
require 'open3'

module Attachs
  class << self

    def configure
      yield configuration
    end

    def configuration
      @configuration ||= Configuration.new
    end

    def storage
      @storage ||= Storages::S3.new
    end

    def models
      if Rails.configuration.cache_classes == false
        Rails.application.eager_load!
      end
      ActiveRecord::Base.descendants.select do |model|
        model.included_modules.include?(Attachs::Concern) && model.descendants.none?
      end
    end

    def each
      models.each do |model|
        model.find_each do |record|
          model.attachments.each do |attribute, options|
            yield record.send(attribute)
          end
        end
      end
    end

    def exists?(path)
      queries = models.map do |model|
        model.attachments.map do |attribute, options|
          joins = []
          if options[:multiple]
            joins << "LEFT JOIN JSONB_ARRAY_ELEMENTS(#{model.table_name}.#{attribute}) attachments ON TRUE"
            joins << "LEFT JOIN JSONB_EACH_TEXT(attachments->'paths') paths ON TRUE"
            joins << "LEFT JOIN JSONB_ARRAY_ELEMENTS_TEXT(attachments->'old_paths') old_paths ON TRUE"
          else
            joins << "LEFT JOIN JSONB_EACH_TEXT(#{model.table_name}.#{attribute}->'paths') paths ON TRUE"
            joins << "LEFT JOIN JSONB_ARRAY_ELEMENTS_TEXT(#{model.table_name}.#{attribute}->'old_paths') old_paths ON TRUE"
          end
          joins = joins.join(' ')
          conditions = ['paths.value = :path OR old_paths.value = :path', path: path]
          model.select('1 AS one').from(model.table_name).joins(joins).where(conditions).to_sql
        end
      end
      query = queries.flatten.join(' UNION ')
      ActiveRecord::Base.connection.execute(query).any?
    end

    def clear
      storage.find_each do |path|
        unless exists?(path)
          Rails.logger.info "Deleting #{path}"
          storage.delete path
        end
      end
    end

    def reprocess
      each do |attachment|
        class_name = attachment.record.class.name
        id = attachment.record.id
        attribute = attachment.record_attribute
        Rails.logger.info "Reprocessing #{class_name} ##{id} => #{attribute}"
        attachment.reprocess
      end
    end

    def fix_missings
      each do |attachment|
        class_name = attachment.record.class.name
        id = attachment.record.id
        attribute = attachment.record_attribute
        Rails.logger.info "Fix missings of #{class_name} ##{id} => #{attribute}"
        attachment.fix_missings
      end
    end

  end
end
