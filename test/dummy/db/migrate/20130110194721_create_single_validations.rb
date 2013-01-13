class CreateSingleValidations < ActiveRecord::Migration
  def change

    create_table :single_validations do |t|
      t.attachment :doc_presence
      t.attachment :doc_content_type
      t.attachment :doc_size
      t.attachment :doc_all
      t.attachment :image_presence
      t.attachment :image_content_type
      t.attachment :image_size
      t.attachment :image_all
      t.timestamps
    end

  end
end
