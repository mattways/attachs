class CreateProducts < ActiveRecord::Migration[5.1]
  def change
    create_table :products do |t|
      t.integer :business_id
      t.string :name

      t.timestamps null: false
    end
  end
end
