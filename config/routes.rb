Rails.application.routes.draw do



require 'sidekiq/web'
require 'sidekiq/cron/web'
  mount Sidekiq::Web => '/sidekiq'

  resources :cases, param: :code do
        member do
              get 'close'
        end
  end
  resources :bookers do
      member do
        get 'pair'
        post 'confirm'
        get 'invite'
      end
      collection do
        get 'waiting'
        get 'sendWaitMessage'
      end
  end
  get 'vax/index'

  get 'vax/nextMessage'
 post 'vax/sendemail'


  resources :clinics do
      member do
        get 'book'
        get 'unbook'
        get 'email'
        get 'sms'
      end
      collection do
        get 'admin'
        get 'checkvaxbooking'
        get 'unbooksearch'
        get 'sendReminder'
        get 'emailreminders'
        get 'updatecontacts'
        get 'smsreminders'
      end
  end
  resources :providers
  resources :tags
  resources :docs do
      collection do
        get 'webpage'
      end
  end


  get 'letters/show'

  get 'database/index'

  get 'database/table'

  get 'database/columns'

  resources :contacts
  get 'fax/index'

  get 'fax/send'

  resources :consults
  resources :itemnumbers
  resources :documents
  resources :recalls
  resources :book do
      collection do
          get 'confirm'
          get 'downloadcal'
          get 'show_appt'
          get 'slots'

      end
  end

  resources :sections do
    resources :chapters
  end
  resources :cells do
      member do
          post 'toggle'
      end
  end
  resources :headers
  resources :paragraphs do
      member do
        get 'touch'
      end
  end
  resources :chapters
  get 'results/index'

  get 'results/show'

  resources :prefs
  get 'agent/index'

resources :appointments do
    collection do
      get 'examen'
      get 'patient_audit'
      get 'prepare'
      post 'image-upload'
      get 'testCME'
    end
end



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
      get 'cst'
      get 'itemcheck'
      get 'log'
      get 'pathways'
      get 'fax'   
      get 'emails'



    end



  end
  

  resources :phonetimes
  get 'nursinghome/index'

  resources :measurements
  resources :measures
  resources :masters
  resources :masters
  resources :goals  do
      member do
        get 'touch'
        post 'priority'
      end
  end
  resources :members
  resources :statuses
  resources :registers do
    resources :headers
  end


  get 'genie/home'
  get 'genie/dashboard'


  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'patient#index', via: [:get, :post]


  resources :images, only: [:create]


  resources :patient do
    resources :results do
      member do
          post 'toggle'
      end

    end
    resources :letters do
          member do
          get 'view'
      end
    end
    resources :referrals 



    resources :members do
        get 'index'
        get 'create'
        get 'update'
         get 'new'
        get 'edit'
        get 'show'
        get 'destroy'



    end
    
    collection do
        get 'index'
        post 'index'
        get 'orion'
        get 'prechecks'

    end
    member do
        get 'careplan'
        get 'annual'
        get 'cma'
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
        post 'consult'
        get 'sendemail'


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
