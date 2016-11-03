module Attachs
  module Extensions
    module ActiveRecord
      module ConnectionAdapters
        module AbstractAdapter

          def add_attachments(table, column)
            add_column table, column, :jsonb, default: []
          end

          def add_attachment(table, column)
            add_column table, column, :jsonb, default: {}
          end

          def remove_attachment(table, column)
            remove_column table, column
          end
          alias_method :remove_attachments, :remove_attachment

        end
        module TableDefinition

          def attachments(name)
            column name, :jsonb, default: []
          end

          def attachment(name)
            column name, :jsonb, default: {}
          end

        end
      end
    end
  end
end
