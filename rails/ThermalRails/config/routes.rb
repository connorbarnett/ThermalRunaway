ThermalRails::Application.routes.draw do
  resources :companies
  match '/vote',  to: 'companies#vote',       via: 'post'
  match '/vote.json', to: 'companies#vote', via: 'post'
  match '/company/getall', to: 'companies#getall', via: 'get'
  match '/company/getall.json', to: 'companies#all', via: 'get'
  match '/company/lookup', to: 'companies#lookup',    via: 'get'
  match '/company/voteinfo', to: 'companies#voteInfo', via: 'get'
  match '/company/getcomparisons', to: 'companies#getcomparisons', via: 'get'
  match '/company/getcomparisons.json', to: 'companies#getcomparisons', via: 'get'
  match '/compare', to: 'companies#compare', via: 'post'
  match '/compare.json', to: 'companies#compare', via: 'post'
  match '/company/compareinfo', to: 'companies#compareInfo', via: 'get'
  match '/company/compareinfo.json', to: 'companies#compareInfo', via: 'get'
  match '/company/comparePercentage', to: 'companies#comparePercentage', via: 'get'
  match '/company/comparePercentage.json', to: 'companies#comparePercentage', via: 'get'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
