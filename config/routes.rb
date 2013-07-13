RailsUploads::Engine.routes.draw do

  get 'uploads/images/:preset/:image.:format', to: 'presets#generate', status: 404

end
