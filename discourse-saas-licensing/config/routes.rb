# frozen_string_literal: true

DiscourseSaas::Engine.routes.draw do
  scope "/license" do
    get "/user/:id" => "licenses#user", constraints: { id: /\d+/ }
    get "/org/:id" => "licenses#organisation", constraints: { id: /\d+/ }
    post "/validate" => "licenses#validate"
  end

  post "/purchases/webhook" => "webhooks#purchases"

  namespace :admin, constraints: StaffConstraint.new do
    resources :license_packages, only: [:index, :create, :update, :destroy]
    resources :organisations, only: [:index, :show] do
      post :invite, on: :member
      delete "member/:user_id" => "organisations#remove_member", on: :member
    end
  end
end
