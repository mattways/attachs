class PrivateImageAttached < ActiveRecord::Base
  has_attached_image :image, presets: [:small, :big], default: 'image.jpg', private: true
end
