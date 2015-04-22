require 'rails_helper'

describe 'Landing' do

  describe "not signed in" do
    it "redirected to index page" do
      visit root_path
      expect( current_path ).to eq beta_path
    end
  end

  describe "real user signed in" do
    it "redirects to their profile page" do
      user = create(:user, role: :member)
      sign_in(user)
      user.member!
      visit root_path
      expect( current_path ).to eq '/'
    end
  end

end