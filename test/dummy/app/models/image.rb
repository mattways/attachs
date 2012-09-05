class Image < ActiveRecord::Base
  
  after_save :create_files, :if => :has_file?
  before_save :generate_filename, :if => :has_file?
  before_destroy :delete_files
  before_update :delete_old_files, :if => :has_file? 
  
  attr_accessible :file
  attr_reader :file  
  
  validates :file, :presence => true, :if => :changed?
  validates :mime, :format => { :with => /jpg|jpeg|png/i }, :allow_blank => true
  validates :size, :numericality => { :less_than => 4 }, :allow_blank => true
  
  def file=(value) 
    self.size = (value.size / (1024 * 1024))
    self.mime = value.content_type.downcase   
    @file = value
  end
  
  def path(preset=nil)
    "/#{File.join('uploads', 'images', preset_name(preset))}" unless new_record?
  end
  
  protected
  
  def has_file?
    self.file.present?
  end
  
  def generate_filename
    extension = File.extname(file.original_filename).downcase
    self.filename = "#{(Time.now.to_f * 1000).to_i}#{extension}"     
  end
  
  def presets
    [
      {:id => '', :width => 0, :height => 0, :method => :crop},   
    ]  
  end
  
  def delete(paths)
    paths.each {|f| File.delete f}   
  end
  
  def delete_files
    paths = [realpath(nil)]
    presets.each {|p| paths << realpath(p[:id])}
    delete paths
  end
  
  def delete_old_files
    paths = [realpath(nil, true)]
    presets.each {|p| paths << realpath(p[:id], true)}
    delete paths
  end    
  
  def preset_name(preset, old=false)
    preset ? (old ? self.filename_was : self.filename).sub('.', "_#{preset}.") : (old ? self.filename_was : self.filename)
  end
  
  def realpath(preset=nil, old=false)
    Rails.root.join('public', 'uploads', 'images', preset_name(preset, old))
  end
  
  def create_files
    File.open(realpath, 'wb') do |file|
      file.write(@file.read)
    end    
    image = Magick::Image.read(realpath).first
    presets.each do |preset|
      case preset[:method]
      when :crop
        thumbnail = image.crop_resized(preset[:width], preset[:height])        
      when :fit
        thumbnail = image.resize_to_fit(preset[:width], preset[:height])        
      end
      thumbnail.write realpath(preset[:id])
    end
  end
  
end