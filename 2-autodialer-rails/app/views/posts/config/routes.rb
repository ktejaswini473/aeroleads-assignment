Rails.application.routes.draw do
  root "call_batches#new"

  resources :call_batches, only: [:index, :show, :new, :create] do
    member do
      post :start
    end
  end

  # AI command endpoint
  post "/ai/command", to: "ai_commands#create", as: :ai_command

  # Twilio
  get  "/twilio/twiml",          to: "twilio#twiml",          as: :twilio_twiml
  post "/twilio/status_callback", to: "twilio#status_callback", as: :twilio_status_callback

  # Blog under /blog
  resources :posts, path: "blog", only: [:index, :show, :new, :create]
end
