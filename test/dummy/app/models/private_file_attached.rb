class PrivateFileAttached < ActiveRecord::Base
  has_attached_file :file, default: 'file.txt', private: true
end
