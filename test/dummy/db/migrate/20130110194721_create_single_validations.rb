class CreateSingleValidations < ActiveRecord::Migration
  def change

    create_table :single_validations do |t|
      t.string :doc_presence
      t.string :doc_content_type
      t.string :doc_size
      t.string :doc_all
      t.string :image_presence
      t.string :image_content_type
      t.string :image_size
      t.string :image_all
      t.timestamps
    end

  end
end
