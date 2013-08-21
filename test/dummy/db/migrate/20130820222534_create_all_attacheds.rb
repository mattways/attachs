class CreateAllAttacheds < ActiveRecord::Migration
  def change
    create_table :all_attacheds do |t|
      t.string :image
      t.string :file_presence
      t.string :file_content_type
      t.string :file_size
      t.string :file_all
      t.string :file_default
      t.string :image_presence
      t.string :image_content_type
      t.string :image_size
      t.string :image_all
      t.string :image_default

      t.timestamps
    end
  end
end
