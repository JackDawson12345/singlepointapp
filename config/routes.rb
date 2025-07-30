Rails.application.routes.draw do
  root "frontend#index"
  devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations',
    passwords: 'users/passwords',
    confirmations: 'users/confirmations',
    unlocks: 'users/unlocks'
  }

  namespace :manage do
    get "/", to: 'dashboard#index', as: 'dashboard'

    get "/account-setup", to: 'account_setup#show', as: 'account_setup'
    patch "/account-setup", to: 'account_setup#update'
    get "/account-setup/:step", to: 'account_setup#show'
    patch "/account-setup/:step", to: 'account_setup#update'

    post 'payments/create-intent', to: 'payments#create_payment_intent'
    post 'payments/confirm', to: 'payments#confirm_payment'

    get "/website", to: 'dashboard#website', as: 'website'
    get "/website/create", to: 'dashboard#website_create', as: 'website_create'
    post "/website/create/save", to: 'dashboard#website_create_save', as: 'website_create_save'

    get "/website/settings", to: 'dashboard#website_settings', as: 'website_settings'

  end

  namespace :admin do
    resources :websites
    resources :theme_page_components
    resources :theme_pages
    resources :themes
    resources :components
    get "/", to: 'dashboard#index', as: 'dashboard'
    get "/themes/:theme_id/theme-page/new", to: 'theme_pages#new', as: 'new_theme_page'
    get "/themes/:theme_id/theme-page/:id/edit", to: 'theme_pages#edit', as: 'edit_theme_page'
    get "/themes/:theme_id/theme-page/:id/", to: 'theme_pages#show', as: 'preview_theme_page'
    get "/themes/:theme_id/theme-page-component/:page_id/new", to: 'theme_page_components#new', as: 'new_theme_page_components'
    patch "/themes/:theme_id/theme-pages/reorder", to: 'themes#reorder', as: 'theme_pages_reorder'
    patch "/themes/:theme_id/theme-page-component/:page_id/new/new_ajax", to: 'theme_page_components#new_ajax', as: 'new_theme_page_components_ajax'
    patch "/themes/:theme_id/theme-page-component/:page_id/update_positions", to: 'theme_page_components#update_positions', as: 'update_theme_page_component_positions'
    delete "/themes/:theme_id/theme-page-component/:page_id/:id/delete_ajax", to: 'theme_page_components#delete_ajax', as: 'delete_theme_page_component_ajax'
  end

end