class Business < ApplicationRecord

  has_attachment(
    :logo,
    styles: {
      tiny: '-resize 25x25^ -gravity center -crop ',
      small: '150x150#',
      medium: '300x300!',
      large: '600x'
    }
  )

  def to_s
    name
  end

end
