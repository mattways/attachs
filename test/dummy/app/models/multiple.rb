class Multiple < ActiveRecord::Base
  attr_accessible :file
  attached_files :file
end
