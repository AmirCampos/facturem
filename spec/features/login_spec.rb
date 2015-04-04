require 'spec_helper'
require 'rails_helper'
require 'ap'

describe "The login process", :type => :feature do
  before do
    @issuer = FactoryGirl.build(:issuer,email: "B57534125@GMAIL.COM", password: "12345")
    @issuer.save!
  end

  feature 'Login to the app' do

    scenario 'with valid user/passw' do
      visit login_path

      try_login_with(@issuer.email,"12345")
      
      expect(page).to have_content @issuer.company_name
    end

    scenario 'with NOT valid user/passw' do
      visit login_path

      try_login_with(@issuer.email, "asdf")
      expect(page).to have_content "Invalid email/password combination"
    end

    def try_login_with(email, password)
      fill_in 'Email', with: email
      fill_in 'Password', with: password

      click_button 'Log in'
    end
  end
end
