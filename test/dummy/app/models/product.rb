class Product < ActiveRecord::Base

  belongs_to :shop

  has_attachments(
    :pictures,
    path: ':id-:style.:extension',
    default_path: 'missing.png'
  )

  has_attachment(
    :brief,
    path: ':id.:extension'
  )

end
