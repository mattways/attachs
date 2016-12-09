class CreateUploads < ActiveRecord::Migration
  def change
    create_table :uploads do |t|
      t.jsonb :file, default: {}
      t.string :record_type
      t.string :record_attribute

      t.timestamps null: false
    end
  end
end
