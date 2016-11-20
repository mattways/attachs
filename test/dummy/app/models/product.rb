class Product < ActiveRecord::Base

  belongs_to :shop

  has_attachments(
    :pictures,
    path: ':id-:style.:extension'
  )

  has_attachment(
    :brief,
    path: ':id.:extension'
  )

end
