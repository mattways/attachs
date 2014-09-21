class CreateMedia < ActiveRecord::Migration
  def change
    create_table :medium do |t|
      t.attachment :attach
      t.attachment :local_attach
      t.attachment :s3_attach

      t.timestamps
    end
  end
end
