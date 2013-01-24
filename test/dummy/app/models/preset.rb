class Preset < ActiveRecord::Base
  attr_accessible :image
  attached_image :image, :presets => { :big => { :method => :fit, :width => 1024, :height => 768  }, :small => { :method => :center, :width => 120, :height => 120 } } 
end
