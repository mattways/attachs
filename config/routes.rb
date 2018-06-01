Attachs::Engine.routes.draw do

  scope controller: :attachments do
    scope path: :files do
      get ':id/:hash', action: :show, as: ''
    end
    scope path: :uploads, format: false do
      root action: :create, via: :post, as: ''
      post ':id(/:chunk)', action: :upload, as: ''
    end
  end

end
