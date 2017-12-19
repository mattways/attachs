class CreateAttachments < ActiveRecord::Migration[5.1]
  def change
    create_table :attachments do |t|
      t.integer :record_id
      t.string :record_base
      t.string :record_type
      t.string :record_attribute
      t.string :content_type
      t.string :extension
      t.integer :size
      t.integer :position, default: 0
      t.string :state, default: 'uploading'
      t.jsonb :extras, default: {}
      t.timestamp :requested_at
      t.timestamp :processed_at
    end

    add_index :attachments, :record_id
    add_index :attachments, :record_base
    add_index :attachments, :record_type
    add_index :attachments, :record_attribute
    add_index :attachments, :position
    add_index :attachments, :state
    add_index :attachments, :requested_at
    add_index :attachments, :processed_at
  end
end
