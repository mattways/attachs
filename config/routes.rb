Attachs::Engine.routes.draw do

  resources :attachments, constraints: { format: 'json' }, only: %i(create show) do
    get :queue, on: :member
  end

end
