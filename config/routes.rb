Rails.application.routes.draw do
  root "welcome#index"
  get "/dashboard" => "dashboard#index"
end
