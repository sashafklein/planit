require 'rails_helper'

describe 'Landing' do

  describe "not signed in" do
    it "redirected to index page" do
      visit root_path
      expect( current_path ).to eq index_path
    end
  end

  describe "pending user signed in" do
    it "redirects to waitlist page" do
      user = create(:user, role: :pending)
      sign_in(user)
      visit root_path
      expect( current_path ).to eq waitlist_path
      visit user_path(user)
      expect( current_path ).to eq waitlist_path
    end
  end

  describe "real user signed in" do
    it "redirects to their profile page" do
      user = create(:user, role: :member)
      sign_in(user)
      user.member!
      visit root_path
      expect( current_path ).to eq user_path(user)
    end
  end

end