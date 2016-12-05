class CreateShops < ActiveRecord::Migration
  def change
    create_table :shops do |t|
      t.string :name
      t.jsonb :files, default: []
      t.jsonb :logo, default: {}

      t.timestamps null: false
    end
  end
end
