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

      expect( page ).to have_content "#{@admin.first_name}, How Can We Improve Planit?"
      
      visit morph_path(@user.id)

      within '.flash-morph' do
        expect( page ).to have_content "Morphed into #{@user.name}. Click to Unmorph."
      end

      expect( page ).to have_content "#{@user.first_name}, How Can We Improve Planit?"
      
      click_link "Morphed into #{@user.name}. Click to Unmorph."
      expect( page ).to have_content "Unmorphed back to #{ @admin.name } successfully."

      visit root_path
      expect( page ).to have_content "#{@admin.first_name}, How Can We Improve Planit?"

      expect( page ).not_to have_content "Morphed into #{@user.name}."
    end

    it "blocks non-admins" do
      sign_in @user

      visit root_path
      expect( page ).to have_content "#{@user.first_name}, How Can We Improve Planit?"
      
      visit morph_path(@admin.id)
      
      expect( page ).to have_content "404"
      expect( page ).not_to have_content "Morphed into"
    end
  end
end