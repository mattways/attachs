class Product < ApplicationRecord

  belongs_to :business, required: false

  has_attachments(
    :pictures,
    default_path: 'missing.png'
  )

  has_attachment :brief

  def to_s
    name
  end

end
