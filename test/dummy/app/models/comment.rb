class Comment < ActiveRecord::Base
  attr_accessible :body, :files
  attached_files :files
  validates :files, :attachment_presence => true
end
