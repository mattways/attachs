class Medium < ActiveRecord::Base
  has_attached_file :attach, path: '/storage/:style/:filename'
  has_attached_file :local_attach, storage: 'local', path: '/storage/:type/:size/:style/:month/:basename.:extension', styles: [:small]
  has_attached_file :s3_attach, storage: 's3', path: '/storage/:type/:size/:style/:month/:basename.:extension', styles: [:small]
end
