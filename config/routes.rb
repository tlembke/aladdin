Rails.application.routes.draw do

  resources :cells do
      member do
          post 'toggle'
      end
  end
  resources :headers
  resources :paragraphs
  resources :chapters
  get 'results/index'

  get 'results/show'

  resources :prefs
  get 'agent/index'

  resources :billing do
    collection do
      get 'index'
      get 'cpp'
      get 'paeds'
      get 'assessments'
      get 'test'
      get 'express'
      get 'pip'
      get 'appointments'
      get 'data'
      get 'bookings'

    end

  end
  

  resources :phonetimes
  get 'nursinghome/index'

  resources :measurements
  resources :measures
  resources :masters
  resources :masters
  resources :goals
  resources :members
  resources :statuses
  resources :registers

  get 'genie/home'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'patient#index', via: [:get, :post]

  resources :patient do
    resources :results
    
    collection do
        get 'index'
        post 'index'
        get 'orion'
        get 'prechecks'

    end
    member do
        get 'careplan'
        get 'annual'
        get 'precheck'
        get 'epc'
        get 'healthsummary'
        get 'import_goals'
        post 'import_goals'
        post 'register'
        get 'conditions'
        get 'billing'
        get 'medications'
        get 'allergies'
        get 'fhir'
    end
  end


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

  post ':controller(/:action(/:id))'
  get ':controller(/:action(/:id))'
end
