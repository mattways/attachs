class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.integer :shop_id
      t.string :name
      t.jsonb :pictures, default: []
      t.jsonb :brief, default: {}

      t.timestamps null: false
    end
  end
end
