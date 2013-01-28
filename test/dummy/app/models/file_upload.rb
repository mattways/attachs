class FileUpload < ActiveRecord::Base
  attr_accessible :file
  attached_file :file, :default => 'file.txt'
end
