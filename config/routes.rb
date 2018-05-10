Attachs::Engine.routes.draw do

  scope Attachs.configuration.prefix, controller: :attachments do
    root action: :create, via: :post
    get ':id/:style', action: :show, via: :get
  end

end
