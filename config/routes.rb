Rails.application.routes.draw do

  resources :user_profiles do
    resources :users
    member do
      post :do_clone
    end
  end

  resources :pre_requisites

  resources :journals, only: [:index, :show]

  resources :user_forms, shallow: true do
    resources :user_form_responses
    get :autocomplete_user_form_name, :on => :collection
  end

  resources :user_form_responses

  resources :periods, only: [:index]

  resources :notifiers

  resources :requests do
    resources :commitments
    member do
      get :candidates
      put :fulfill
      put :unfulfill
    end
  end

  resources :exam_cycles do
    resources :proto_events do
      member do
        post :generate
      end
    end
  end

  resources :proto_events, only: [:split] do
    member do
      post :split
    end
  end

  resources :posts do
      resources :comments, except: [:show, :edit, :update, :destroy]
  end
  resources :comments, only: [:show, :edit, :update, :destroy]

  #
  #  I don't seem to be able to achieve this by means of the shallow
  #  modifier, because it recurses into inner nestings and can't
  #  be turned off again.  I can't make things properly shallow because
  #  Backbone doesn't work that way.
  #
  resources :rota_template_types do
    resources :rota_templates, except: [:show, :edit, :update, :destroy]
  end

  resources :rota_templates, only: [:show, :update, :destroy] do
    resources :rota_slots
    member do
      post :do_clone
    end
  end

#  resources :rota_template_types, shallow: true do
#    resources :rota_templates
#      resources :rota_slots
#      member do
#        post :do_clone
#      end
#    end
#  end

  resources :settings

  get '/auth/:provider/callback' => 'sessions#create'
  get '/signin' => 'sessions#new', :as => :signin
  get '/signout' => 'sessions#destroy', :as => :signout
  get '/auth/failure' => 'sessions#failure'

  get 'sessions/new'

  get 'sessions/create'

  get 'sessions/destroy'

  get 'sessions/demo_login'
 
  put 'sessions/become/:user_id' => 'sessions#become', as: :become

  get '/ical/:id' => 'elements#ical'

  resources :locationaliases

  resources :groups do
    member do
      get :members
      post :do_clone
      post :flatten
    end

  end

  resources :freefinders

  resources :tutorgroups

  resources :locations

  resources :pupils

  resources :properties

  resources :services

  resources :subjects

  resources :users do
    get :autocomplete_user_name, :on => :collection
    get :pp, :on => :collection
    resources :filters, only: [:edit, :update]
    resources :events, only: [:index]
    #
    #  One would not normally make :destroy and :edit for concerns
    #  subsidiary to users, but we do it to distinguish such
    #  requests from those for the current user.  It's a completely
    #  different area of dialogues.
    #
    resources :concerns, only: [:create, :destroy, :edit]
  end

  resources :commitments do
    member do
      put :approve
      put :reject
      put :noted
      put :ajaxapprove
      put :ajaxreject
      put :ajaxnoted
    end
  end

  post '/commitments/:commitment_id/coverwith/:id', to: 'covers#coverwith'

  resources :memberships

  resources :staffs

  resources :events do
    resources :notes, shallow: true
    resources :requests
    resources :wrappers, only: [:new, :create]
    member do
      get :shownotes
      get :canceledit
      get :coverrooms
      put 'moved'
      post :clone
      post :upload
    end
    get :search, :on => :collection
  end

  resources :days do
    get :index, :on => :collection
  end

  resources :datasources

  resources :eventsources

  resources :eventcategories do
    get :autocomplete_eventcategory_name, :on => :collection
  end

  resources :interests

  resources :concerns do
    member do
      put :flipped
    end

    collection do
      get :sidebar
    end

  end

  resources :itemreports

  resources :elements do
    resources :promptnotes, shallow: true
    resources :journal_entries, only: [:index]
    resources :commitments, only: [:index]
    get :autocomplete_element_name, :on => :collection
    get :autocomplete_unowned_element_name, :on => :collection
    get :autocomplete_staff_element_name, :on => :collection
    get :autocomplete_group_element_name, :on => :collection
    get :autocomplete_property_element_name, :on => :collection
    get :autocomplete_location_element_name, :on => :collection
    get :ical, :on => :member

  end

  resources :item do
    resources :days do
      get :index, :on => :collection
    end
  end

  get 'schedule/show'
  get 'schedule/events'
  put 'schedule/change_time'

#  resources :imports

  get 'imports/index'
  post 'imports/upload'
  delete 'imports/delete'
  get 'imports/check_file'
  post 'imports/commit_file'

  resources :eras

  root 'schedule#show'

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
