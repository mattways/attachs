class ImageUpload < ActiveRecord::Base
  attr_accessible :image
  attached_image :image, :presets => [:small, :big], :default => 'assets/image.jpg'
end
