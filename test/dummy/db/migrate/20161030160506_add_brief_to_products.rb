class AddBriefToProducts < ActiveRecord::Migration
  def change
    add_attachment :products, :brief
  end
end
