Attachs::Engine.routes.draw do

  resources :attachments, path: '', format: false, defaults: { format: 'json' }, only: %i(create show) do
    get :queue, on: :member
  end

end
