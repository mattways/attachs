class CreateMedia < ActiveRecord::Migration
  def change
    create_table :media do |t|
      t.attachment :attach
      t.attachment :local_attach
      t.attachment :s3_attach

      t.timestamps
    end
  end
end
