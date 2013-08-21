class ImageAttached < ActiveRecord::Base
  attached_image :image, presets: [:small, :big], default: 'image.jpg'
end
