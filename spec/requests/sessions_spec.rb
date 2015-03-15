require 'rails_helper'

RSpec.describe "Sessions", :type => :request do
  describe "GET /login" do
    it "login, go to login page" do
      get login_path
      expect(response).to have_http_status(200)
      assert_template 'sessions/new'
    end
  end
end
