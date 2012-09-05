class Audio < ActiveRecord::Base
  
  after_save :create_file, :if => :has_file?
  before_save :generate_filename, :if => :has_file?  
  before_destroy :delete_file
  before_update :delete_old_file, :if => :has_file? 
  
  attr_accessible :file
  attr_reader :file
  
  validates :file, :presence => true, :if => :changed?
  validates :mime, :format => { :with => /mpeg/i }, :allow_blank => true
  validates :size, :numericality => { :less_than => 10 }, :allow_blank => true  
  
  def file=(value) 
    self.name = File.basename(value.original_filename, '.*')
    self.size = (value.size / (1024 * 1024))
    self.mime = value.content_type.downcase
    @file = value
  end
  
  def path
    "/#{File.join('uploads', 'audios', self.filename)}" unless new_record?
  end
  
  protected
  
  def has_file?
    self.file.present?
  end  
  
  def generate_filename
    extension = File.extname(file.original_filename).downcase
    self.filename = "#{(Time.now.to_f * 1000).to_i}#{extension}"     
  end  
  
  def delete_file
    File.delete realpath
  end
  
  def delete_old_file
    File.delete realpath(true)
  end
  
  def realpath(old=false)
    Rails.root.join('public', 'uploads', 'audios', (old ? self.filename_was : self.filename))
  end
  
  def create_file
    File.open(realpath, 'wb') do |file|
      file.write(@file.read)
    end
  end
  
end