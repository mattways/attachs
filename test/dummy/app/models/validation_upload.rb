class ValidationUpload < ActiveRecord::Base
  attr_accessible :file_presence, :file_content_type, :file_size, :file_all, :image_presence, :image_content_type, :image_size, :image_all
  attached_file :file_presence, :file_content_type, :file_size, :file_all
  attached_file :file_default, :default => 'default.txt'
  attached_image :image_presence, :image_content_type, :image_size, :image_all, :presets => [:big]
  attached_image :image_default, :presets => [:big, :small], :default => 'default.jpg'
  validates :file_presence, :attachment_presence => true
  validates :file_content_type, :attachment_content_type => { :in => ['txt'] }
  validates :file_size, :attachment_size => { :less_than => 15.kilobytes, :greater_than => 10.bytes }
  validates :file_all, :attachment_presence => true, :attachment_content_type => { :in => ['txt'] }, :attachment_size => { :less_than => 15.kilobytes, :greater_than => 10.bytes }
  validates :file_default, :attachment_presence => true, :attachment_content_type => { :in => ['txt'] }, :attachment_size => { :less_than => 15.kilobytes, :greater_than => 10.bytes }
  validates :image_presence, :attachment_presence => true
  validates :image_content_type, :attachment_content_type => { :in => ['jpg'] }
  validates :image_size, :attachment_size => { :in => 2.kilobytes..60.kilobytes }
  validates :image_all, :attachment_presence => true, :attachment_content_type => { :in => ['jpg'] }, :attachment_size => { :in => 2.kilobytes..60.kilobytes }
  validates :image_default, :attachment_presence => true, :attachment_content_type => { :in => ['jpg'] }, :attachment_size => { :in => 2.kilobytes..60.kilobytes }
end
