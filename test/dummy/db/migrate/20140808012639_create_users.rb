class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :email
      t.attachment :avatar

      t.timestamps
    end
  end
end
