class Preset < ActiveRecord::Base
  attr_accessible :image
  attached_image :image, :presets => {
    :small => { :width => 314, :height => 206 },
    :big => { :width => 500, :height => 360 }
  }
end
