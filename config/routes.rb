Attachs::Engine.routes.draw do

  scope path: :files, controller: :files do
    root action: :create, via: :post, as: :files
    get ':id/:hash', action: :show, as: :file
  end

end
