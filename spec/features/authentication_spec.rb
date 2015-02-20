require 'rails_helper'

describe 'Authentication' do

  describe "sign in" do
    it "is linked to on the landing page" do
      user = create(:user)
      visit root_path
      
      expect( page ).to have_content 'LOG IN' # On sign-in page
      fill_in 'Email', with: user.email
      fill_in "Password", with: user.password
      click_button 'Sign in'

      expect( current_path ).to eq user_path(user)
    end
  end

  describe 'private beta registration' do
    xit "allows new users to register" do
      visit root_path
      
      click_link 'Sign up'
      fill_in 'Email', with: 'myfake@email.com'
      fill_in 'Password', with: 'password'
      fill_in 'Password confirmation', with: 'password'
      fill_in 'First name', with: 'John'
      fill_in 'Last name', with: 'Doe'
      click_button "Sign up"

      expect( current_path ).to eq '/users/john-doe'
      expect( page ).to have_content "Welcome! You have signed up successfully."
    end
  end

  describe 'public beta registration' do
    xit "allows new users to join waitlist" do
      visit root_path
      
      click_link 'Sign up'
      fill_in 'Email', with: 'myfake@email.com'
      fill_in 'Password', with: 'password'
      fill_in 'Password confirmation', with: 'password'
      fill_in 'First name', with: 'John'
      fill_in 'Last name', with: 'Doe'
      click_button "Sign up"

      expect( current_path ).to eq '/users/john-doe'
      expect( page ).to have_content "Welcome! You have signed up successfully."
    end
  end
end