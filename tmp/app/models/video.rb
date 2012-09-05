class Video < ActiveRecord::Base
  
  before_save :extract_id  
  
  attr_accessible :youtube_url  
  
  validates :youtube_url, :presence => true
  validates :youtube_url, :length => { :maximum => 255 }
  validates :youtube_url, :format => { :with => /(v=|\/)([\w-]+)(&.+)?$/ }, :allow_blank => true
  
  def path
    "http://img.youtube.com/vi/#{self.youtube_id}/mqdefault.jpg" unless new_record?
  end  
  
  protected
  
  def extract_id
    self.youtube_id = /(v=|\/)([\w-]+)(&.+)?$/.match(self.youtube_url)[2]
  end
  
end