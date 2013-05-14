RailsUploads::Engine.routes.draw do

  match 'uploads/images/:preset/:image.:format' => 'presets#generate', :status => 404

end
