class CreateImageAttacheds < ActiveRecord::Migration
  def change
    create_table :image_attacheds do |t|
      t.string :image

      t.timestamps
    end
  end
end
