class CreateSingles < ActiveRecord::Migration
  def change

    create_table :singles do |t|
      t.attachment :file
      t.timestamps
    end

  end
end
