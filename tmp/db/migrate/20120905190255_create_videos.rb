class CreateVideos < ActiveRecord::Migration
  def change
    create_table :videos do |t|
      t.string :youtube_url, :null => false
      t.string :youtube_id, :null => false
      t.integer :videable_id, :null => false
      t.string :videable_type, :null => false
      t.timestamps          
    end    
    add_index :videos, :youtube_url    
    add_index :videos, :youtube_id 
    add_index :videos, :videable_id
    add_index :videos, :videable_type
    add_index :videos, :created_at
    add_index :videos, :updated_at
  end
end