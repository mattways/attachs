class FileUpload < ActiveRecord::Base
  attr_accessible :file
  attached_file :file, :default => 'default.txt'
end
