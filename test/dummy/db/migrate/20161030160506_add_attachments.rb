class AddAttachments < ActiveRecord::Migration
  def change
    add_attachment :products, :brief
    add_attachments :shops, :files
  end
end
