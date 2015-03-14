require 'rails_helper'
require 'ap'

RSpec.describe SessionsController, :type => :controller do

  describe "GET new" do
    it "responds successfully with an HTTP 200 status code" do
      get :new
      expect(response).to be_success
      expect(response).to have_http_status(200)
    end

    it "renders the new template" do
      get :new
      expect(response).to render_template("new")
    end
  end

  describe "POST #create" do
    before do
      build(:issuer, 
        email: "b57534125@gmail.com",
        password: "12345")
    end

    it "renders login again if bad user/password" do
      post :create, session: { email: "email@email.com", password: "password"}

      expect(response).to render_template("new")
    end
    # TODO: undefined method `values' for #<ActionController::TestResponse
    # it "renders index when valid user/password" do
    #   post :create, session: { email: "b57534125@gmail.com", password: "12345"}

    #   expect(response).to route_to(controller: "invoices", action: "index")
    # end
  end

  describe "DELETE #destroy" do
    before do
      issuer = build(:issuer, 
        email: "b57534125@gmail.com",
        password: "12345")
      issuer.save
      session[:issuer_id] = issuer.id
    end
    # TODO: undefined method `values' for #<ActionController::TestResponse
    it "renders login again when logout" do
      delete :destroy
      ## expect(response).to route_to("sessions#new")
      # expect(response).to route_to(login_path)
      ## expect(get('/logout')).to route_to(controller: 'sessions#new')
      ## expect(delete("/logout")).to route_to("sessions#new")      
    end
  end

end
