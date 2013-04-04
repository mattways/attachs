Rails::Uploads::Engine.routes.draw do

  match 'uploads/images/:preset/:image' => 'presets#generate', :status => 404

end
