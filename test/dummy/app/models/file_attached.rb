class FileAttached < ActiveRecord::Base
  has_attached_file :file, default: 'file.txt'
end
