Attachs::Engine.routes.draw do

  scope path: :files, controller: :files do
    root action: :create, via: :post
    post ':id(/:chunk)', action: :upload
    get ':id/:hash', action: :show, as: :file
  end

end
