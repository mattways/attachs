require 'test_helper'

class MigrationTest < ActiveSupport::TestCase

  setup do
    ActiveRecord::Migration.verbose = false
  end

  test 'table migration' do
    table_migration.migrate(:up)
    assert_includes columns, ['image_filename', :string]
    assert_includes columns, ['image_size', :integer]
    assert_includes columns, ['image_content_type', :string]
    assert_includes columns, ['image_updated_at', :datetime]

    assert_nothing_raised do
      table_migration.migrate(:down)
    end
  end

  test 'column migration' do
    ActiveRecord::Base.connection.create_table :pictures

    column_migration.migrate(:up)
    assert_includes columns, ['image_filename', :string]
    assert_includes columns, ['image_size', :integer]
    assert_includes columns, ['image_content_type', :string]
    assert_includes columns, ['image_updated_at', :datetime]

    column_migration.migrate(:down)
    refute_includes columns, ['image_filename', :string]
    refute_includes columns, ['image_size', :integer]
    refute_includes columns, ['image_content_type', :string]
    refute_includes columns, ['image_updated_at', :datetime]
  end

  private

  def columns
    Picture.reset_column_information
    Picture.columns.map { |column| [column.name, column.type] }
  end

  def table_migration
    Class.new(ActiveRecord::Migration) do
      def change
        create_table :pictures do |t|
          t.attachment :image
        end
      end
    end
  end

  def column_migration
    Class.new(ActiveRecord::Migration) do
      def up
        add_attachment :pictures, :image
      end
      def down
        remove_attachment :pictures, :image
      end
    end
  end

end
