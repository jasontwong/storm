DataApi::Application.routes.draw do
  resources :survey_question_categories, except: [:new, :edit]

  resources :member_surveys, except: [:new, :edit, :create, :destroy]

  resources :member_survey_answers, except: [:new, :edit, :create, :destroy]

  resources :clients, except: [:new, :edit]

  resources :survey_questions, except: [:new, :edit]

  resources :orders, except: [:new, :edit]

  resources :codes, except: [:new, :edit]

  resources :surveys, except: [:new, :edit]

  resources :rewards, except: [:new, :edit]

  resources :products, except: [:new, :edit]

  resources :stores, except: [:new, :edit]

  resources :companies, except: [:new, :edit]

  # custom routes
  get 'members/:id/points' => 'members#point_index', as: :member_points
  get 'members/:id/rewards' => 'members#reward_index', as: :member_rewards
  post 'members/:id/rewards' => 'members#reward_create'
  put 'members/:member_id/rewards/:id' => 'members#reward_update', as: :member_reward
  post 'members/verify' => 'members#verify'
  post 'members/fb_verify' => 'members#fb_verify'
  put 'members/pass_reset' => 'members#pass_reset'
  post 'codes/scan' => 'codes#scan'

  resources :members, except: [:new, :edit]

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
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

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
