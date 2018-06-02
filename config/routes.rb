Attachs::Engine.routes.draw do

  scope controller: :attachments do
    scope path: :storage do
      get ':id/:hash', action: :show, as: ''
    end
    scope path: :upload, format: false do
      root action: :create, via: :post, as: ''
      post ':id(/:chunk)', action: :upload, as: ''
    end
  end

end
