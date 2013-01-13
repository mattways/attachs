class CreateMultiples < ActiveRecord::Migration
  def change

    create_table :multiples do |t|
      t.attachments :files
      t.timestamps
    end

  end
end
