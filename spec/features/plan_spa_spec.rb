require 'rails_helper'

describe 'Root SPA' do

  describe "creation/editing flow" do

    before do
      # Capybara.current_driver = Capybara.javascript_driver
      @user = create(:user)
      sign_in @user
      ENV['RENDER_JS'] = 'true'
    end

    # after do
    #   Capybara.use_default_driver
    # end

    it "allows for creation, addition, note-taking, map-viewing, renaming, and deletion", :js, :vcr do
      visit root_path
      expect( page ).to have_content "Start a new plan"
      fill_in 'plan-nearby', with: 'San Francisco'

      within 'ul.suggested-results' do
        first('li').click
      end

      expect( page ).to have_content "Cool! Now Add Places to your List"
      
      # Auto-named the plan
      within '.setplanbox-on-plan-page' do
        expect( page ).to have_content "San Francisco"
        first('i.fa-pencil.rename').click
        fill_in 'rename', with: 'My SF Plan!'
      end

      within '.rename-confirmation' do
        first('.planit-button.neon').click
      end

      within '.setplanbox-on-plan-page' do
        expect( page ).to have_content "My SF Plan!"
      end

      within '.input-and-results' do
        fill_in 'place-name', with: 'Contigo'
        within 'ul.suggested-results' do
          first('li').click
        end
      end

      expect( page ).to have_content "ADDING CONTIGO TO YOUR PLAN"

      wait_for(selector: '.plan-list-items')

      within '.plan-list-items' do
        expect( page ).to have_content "Contigo"
        expect( page ).to have_content "Spanish Restaurant"
        binding.pry
        within '.items-organized-by.magenta' do
          expect( page ).to have_content "Food"
        end
        within '.list-item-notes' do
          fill_in 'Add a note', with: 'My favorite local spot!'
        end
      end

      expect( full_path ).to include Plan.first.id.to_s


      binding.pry
    end
  end

end