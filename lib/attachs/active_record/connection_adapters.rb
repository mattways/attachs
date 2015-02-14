module Attachs
  module ActiveRecord
    module ConnectionAdapters
      COLUMNS = {
        filename: 'string',
        content_type: 'string',
        size: 'integer',
        updated_at: 'datetime'
      }

      module AbstractAdapter
        def add_attachment(table_name, *attachment_names)
          attachment_names.each do |attachment_name|
            COLUMNS.each do |column_name, column_type|
              add_column table_name, "#{attachment_name}_#{column_name}", column_type
            end
          end
        end

        def remove_attachment(table_name, *attachment_names)
          attachment_names.each do |attachment_name|
            COLUMNS.each do |column_name, column_type|
              remove_column table_name, "#{attachment_name}_#{column_name}"
            end
          end
        end
      end

      module TableDefinition
        def attachment(*attachment_names)
          attachment_names.each do |attachment_name|
            COLUMNS.each do |column_name, column_type|
              column "#{attachment_name}_#{column_name}", column_type
            end
          end
        end
      end
    end
  end
end
