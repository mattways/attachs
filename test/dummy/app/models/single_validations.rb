class SingleValidations < ActiveRecord::Base
  attr_accessible :doc_presence, :doc_content_type, :doc_size, :doc_all, :image_presence, :image_content_type, :image_size, :image_all
  attached_file :doc_presence, :doc_content_type, :doc_size, :doc_all 
  attached_image :image_presence, :image_content_type, :image_size, :image_all
  validates :doc_presence, :attachment_presence => true
  validates :doc_content_type, :attachment_content_type => { :in => ['txt'] }
  validates :doc_size, :attachment_size => { :less_than => 15.kilobytes, :greater_than => 10.bytes }
  validates :doc_all, :attachment_presence => true, :attachment_content_type => { :in => ['txt'] }, :attachment_size => { :less_than => 15.kilobytes, :greater_than => 10.bytes }
  validates :image_content_type, :attachment_content_type => { :in => ['jpg'] }
  validates :image_size, :attachment_size => { :in => 2.kilobytes..60.kilobytes }
  validates :image_all, :attachment_content_type => { :in => ['jpg'] }, :attachment_size => { :in => 2.kilobytes..60.kilobytes }
end
