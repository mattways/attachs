class FileUpload < ActiveRecord::Base
  attr_accessible :file
  attached_file :file, :default => 'files/file.txt'
end
