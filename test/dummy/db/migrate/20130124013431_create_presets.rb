class CreatePresets < ActiveRecord::Migration
  def change
    
    create_table :presets do |t|
      t.attachment :image
      t.timestamps
    end

  end
end
