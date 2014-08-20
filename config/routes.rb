Rails.application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # custom routes
  get 'api_key/generate' => 'api_key#generate'
  get 'stats/analytics' => 'stats#analytics'
  get 'stats/surveys' => 'stats#surveys'
  get 'stats/surveys/:id' => 'stats#survey'
  get 'members/:id/points' => 'members#point_index', as: :member_points
  post 'members/verify' => 'members#verify'
  post 'members/fb_verify' => 'members#fb_verify'
  put 'members/pass_reset' => 'members#pass_reset'
  post 'codes/scan' => 'codes#scan'
  post 'codes/beacon' => 'codes#beacon'
  post 'clients/verify' => 'clients#verify'
  post 'companies/:id/beacon_verify' => 'companies#beacon_verify'
  post 'clients/pass_reset' => 'clients#pass_reset'
  post 'clients/pass_generate' => 'clients#pass_generate'
  post 'ios/check_version' => 'ios#check_version'
  get 'companies/create_payload' => 'companies#create_payload'

  resources :survey_question_categories, except: [:new, :edit]

  resources :member_surveys, except: [:new, :edit, :create, :destroy]

  resources :member_survey_answers, except: [:new, :edit, :create, :destroy]

  resources :clients, except: [:new, :edit]

  resources :survey_questions, except: [:new, :edit]

  resources :codes, except: [:new, :edit]

  resources :surveys, except: [:new, :edit]

  resources :rewards, except: [:new, :edit]

  resources :member_rewards, except: [:new, :edit, :destroy]

  resources :stores, except: [:new, :edit]

  resources :companies, except: [:new, :edit]

  resources :members, except: [:new, :edit]

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
