class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.text :body
      t.attachment :files, :multiple => true
      t.timestamps
    end
  end
end
