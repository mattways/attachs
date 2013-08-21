class CreateFileAttacheds < ActiveRecord::Migration
  def change
    create_table :file_attacheds do |t|
      t.string :file

      t.timestamps
    end
  end
end
