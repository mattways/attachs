class Business < ApplicationRecord

  has_attachment(
    :logo,
    styles: {
      tiny: '25x25',
      small: '150x150#',
      medium: '300x300!',
      large: '600x'
    }
  )

  def to_s
    name
  end

end
