class CreateAttachments < ActiveRecord::Migration[5.1]
  def change
    create_table :attachments do |t|
      t.integer :record_id
      t.string :record_type
      t.string :record_base
      t.string :record_attribute
      t.string :content_type
      t.string :extension
      t.integer :size
      t.integer :position, default: 0
      t.jsonb :metadata, default: {}

      t.timestamps
    end

    add_index :attachments, :record_id
    add_index :attachments, :record_type
    add_index :attachments, :record_base
    add_index :attachments, :record_attribute
    add_index :attachments, :position
  end
end
