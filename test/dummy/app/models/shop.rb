class Shop < ActiveRecord::Base

  has_attachment(
    :logo,
    path: ':name/:id-:style.png',
    styles: {
      tiny: '25x25',
      small: '150x150#',
      medium: '300x300!',
      large: '600x'
    }
  )

end
