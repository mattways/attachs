class Single < ActiveRecord::Base
  attr_accessible :file
  attached_file :file
end
