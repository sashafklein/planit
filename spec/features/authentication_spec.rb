require 'spec_helper'

describe 'Authentication', driver: :selenium do

  describe "sign in" do
    it "is linked to on the landing page" do
      user = create(:user)
      sleep 1
      visit root_path
      sleep 2
      expect( page ).to have_content 'LOG IN' # On sign-in page
      sleep 1
      fill_in 'Email', with: user.email
      sleep 1
      fill_in "Password", with: user.password
      sleep 1
      click_button 'Sign in'
      
      expect( current_path ).to eq user_path(user)
    end
  end

  describe 'registration' do
    it "allows new users to register" do
      visit root_path
      click_link 'Sign up'
      sleep 2
      fill_in 'Email', with: 'myfake@email.com'
      fill_in 'Password', with: 'password'
      sleep 1
      fill_in 'Password confirmation', with: 'password'
      fill_in 'First name', with: 'John'
      fill_in 'Last name', with: 'Doe'

      click_button "Sign up"

      expect( current_path ).to include '/users/'
      expect( page ).to have_content "Welcome! You have signed up successfully."
    end
  end
end