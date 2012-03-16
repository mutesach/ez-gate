EzGate::Application.routes.draw do
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id'  'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase'  'catalog#purchase', :as  :purchase
  # This route can be invoked with purchase_url(:id  product.id)

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

  resources :messages do
    collection do
      get 'inbound'
      get  'outbound'
      get  'new_message'
      get 'compose_new_message'
      get  'get_all'
      get  'update_incoming'
      post  'search_by_service'
      post  'search_by_destination'
      post  'search_by_date'
      post  'search_by_sender'
      post  'search_by_content'
      get  'filter_by'
      get  'disp_inbound_message'
      get  'disp_outbound_message'
      get  'view_inbound_message'
      get  'view_outbound_message'
      get  'new_message'
      post  'send_message'
      get  'single_message_box'
      get  'reply_message_box'
      get  'reply_message'
      get  'multi_message_box'
      get  'multi_sel_message_box'
      get  'single_message'
      get  'multi_message'
      get  'send_single_message'
      get  'send_multi_message'
      get  'check_gateway_status'
      get  'send_sms'
      get  'toggle_completed'
    end
  end
  resources :settings do
    collection do
      get 'new_short_code'
      post 'new_short_code'
      get 'assign_short_code'
      post 'assign_short_code'
      get 'edit_assigned_short_code'
      get 'edit_short_code'
      post 'update_short_code'
      post 'update_assigned_short_code'
      post 'delete_short_code'
      post 'new_web_service'
      get 'new_web_service'
      get 'edit_web_service'
      post 'update_web_service'
      post 'delete_web_service'
      get 'activate_short_code'
      get 'deactivate_short_code'
      post 'resume_kannel'
      post 'isolate_kannel'
      post 'restart_kannel'
      post 'start_kannel'
      post 'update_kannel_conf'
      get 'upload_file'
      get 'new_ringtone'
      post 'new_ringtone'
      get 'deactivate_ringtone'
      get 'activate_ringtone'
      get 'edit_ringtone'
      post 'save_ringtone'
      post 'update_ringtone'
      get 'view_ringtones'
    end
  end
  resources :users do
    collection do
      get 'new_user'
      post 'save_user'
      post 'delete_user'
      get 'edit_user'
      get 'edit_user_profile'
      get 'update_user_profile'
      get 'change_password'
      post 'change_password'
      get 'activate_user'
      get 'deactivate_user'
      get 'disp_user_profile'
      get 'view_user_profile'
      
    end
  end
  resources :contacts do
    collection do
      get 'new_contact'
      post 'new_contact'
      get 'edit_contact'
      post 'update_contact'
      get 'new_group'
      post 'new_group'
      get 'receive_drop'
      get 'drop_group'
      post 'manage_contacts'
      post 'send_sms'
      get 'check_gateway_status'
      post 'csv_import'
      get 'new_directory'
      post 'new_directory'
      post 'import_directory'
      get 'view_directory'
      post 'search_directory'
      get 'delete_directory'
    end
  end
  resources :services do
    collection do
      get 'list'
      get 'dynamic_codes'
      get 'new_service'
      post 'new_service'
      get 'new_user_mod'
      post 'new_user_mod'
      get 'delete_mod_user'
      get 'add_service_mod'
      post 'add_service_mod'
      get 'remove_service_mod'
      get 'delete_user_service_mod'
      get 'update_service_mod'
      post 'update_service_mod'
      get 'activate_user_mod'
      get 'deactivate_user_mod'
      get 'edit_service'
      post 'update_service'
      get 'enable_service'
      get 'disable_service'
      get 'disp_service'
      get 'view_service_details'
    end
  end
  resources :login do
    collection do
      post 'login'
      get 'logout'
      get 'login'
    end
  end
  resources :report do
    collection do
      post 'custom_request_outbound'
      post 'custom_request_inbound'
      post 'summary'
    end
  end

  resources :service_manager do
    collection do
      get 'request_handler'
      get 'record_push'
      get 'service_test'
      get 'get_ringtone'
    end
  end

  resources :ringtones do
    collection do
      get 'index'
      get 'download_ringtone'
      post 'download_ringtone'
    end
  end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on  :collection
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


  root :to =>  'login#login'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
