class ImageGenerator < Rails::Generators::Base
  
  include Rails::Generators::Migration  
  source_root File.expand_path('../templates', __FILE__)
  
  def create_model
    template 'image_model.rb.erb', 'app/models/image.rb'     
  end
  
  def create_migration
    migration_template 'image_migration.rb.erb', 'db/migrate/create_images'
  end  
  
  def create_upload_dir
    empty_directory 'public/uploads/images'   
  end
  
  def self.next_migration_number(path)
    Time.now.utc.strftime('%Y%m%d%H%M%S')
  end  
  
end