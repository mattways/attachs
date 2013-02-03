RailsUploads::Engine.routes.draw do

  match 'uploads/images/:preset/:image' => 'uploads#generate_image_preset', :status => 404

end
