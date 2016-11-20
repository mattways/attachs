class CreateUploads < ActiveRecord::Migration
  def change
    create_table :uploads do |t|
      t.attachment :file
      t.string :record_type
      t.string :record_attribute

      t.timestamps null: false
    end
  end
end
