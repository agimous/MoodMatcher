Rails.application.routes.draw do



  get 'welcome/index'
  get 'welcome/show'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'welcome#index'
  
  resources :moods
  
  resources :users do
	resources :lists 
	resources :albums
		
  end
  
  get    '/signup',  to: 'users#new'
  get    '/login',   to: 'sessions#new'
  post   '/login',   to: 'sessions#create'
  delete '/logout',  to: 'sessions#destroy'

end
