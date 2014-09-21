class User < ActiveRecord::Base
  has_attached_file :attach, path: '/:style/:filename'
end
