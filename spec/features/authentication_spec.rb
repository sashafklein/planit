require 'spec_helper'

describe 'Authentication', driver: :selenium do

  describe "sign in" do
    it "is linked to on the landing page" do
      user = create(:user)
      visit root_path

      sleep 4
      
      expect( page ).to have_content 'LOG IN' # On sign-in page
      sleep 1
      fill_in 'Email', with: user.email
      sleep 1
      fill_in "Password", with: user.password
      sleep 1
      click_button 'Sign in'
      sleep 1
      
      expect( current_path ).to eq user_path(user)
    end
  end

  describe 'registration' do
    it "allows new users to register" do
      visit root_path

      sleep 4
      
      click_link 'Sign up'
      sleep 1
      fill_in 'Email', with: 'myfake@email.com'
      sleep 1
      fill_in 'Password', with: 'password'
      sleep 1
      fill_in 'Password confirmation', with: 'password'
      sleep 1
      fill_in 'First name', with: 'John'
      sleep 1
      fill_in 'Last name', with: 'Doe'
      sleep 1
      click_button "Sign up"
      sleep 1

      expect( current_path ).to include '/users/'
      sleep 1
      expect( page ).to have_content "Welcome! You have signed up successfully."
    end
  end
end