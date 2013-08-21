class FileAttached < ActiveRecord::Base
  attached_file :file, default: 'file.txt'
end
