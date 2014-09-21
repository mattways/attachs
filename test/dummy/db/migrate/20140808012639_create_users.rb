class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :email
      t.attachment :attach

      t.timestamps
    end
  end
end
