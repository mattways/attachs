class CreateFileUploads < ActiveRecord::Migration
  def change

    create_table :file_uploads do |t|
      t.string :file
      t.timestamps
    end

  end
end
