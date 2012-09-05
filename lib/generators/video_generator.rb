class VideoGenerator < Rails::Generators::Base
  
  include Rails::Generators::Migration
  source_root File.expand_path('../templates', __FILE__)
  
  def create_model
    template 'video_model.rb.erb', 'app/models/video.rb'   
  end
  
  def create_migration
    migration_template 'video_migration.rb.erb', 'db/migrate/create_videos'
  end  
  
  def create_upload_dir
    empty_directory 'public/uploads/videos'     
  end
  
  def self.next_migration_number(path)
    Time.now.utc.strftime('%Y%m%d%H%M%S')
  end  
  
end