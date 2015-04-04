require 'rails_helper'

describe 'Morphing' do

  before do 
    @user = create(:user, role: :member)
    @admin = create(:user, role: :admin, first_name: 'Admin', last_name: 'McAdminson')
  end

  describe "morph/unmorph" do
    it "morphs admins into the user" do
      sign_in @admin

      visit root_path
      expect( page ).to have_content @admin.name
      
      visit morph_path(@user.id)
      
      expect( page ).to have_content "Morphed into #{@user.name}. Click to Unmorph."
      expect( page ).not_to have_content @admin.name
      
      click_link "Morphed into #{@user.name}. Click to Unmorph."

      expect( page ).to have_content @admin.name
      expect( page ).not_to have_content "Morphed into #{@user.name}."
    end

    it "blocks non-admins" do
      sign_in @user

      visit root_path
      expect( page ).to have_content @user.name
      
      visit morph_path(@admin.id)
      
      expect( page ).to have_content "404"
      expect( page ).not_to have_content "Morphed into"
    end
  end
end