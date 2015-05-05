require 'rails_helper'

describe 'Root SPA' do

  describe "creation/editing flow" do

    before do
      @user = create(:user)
      sign_in @user
      ENV['RENDER_JS'] = 'true'
    end

    it "allows for creation, addition, note-taking, map-viewing, renaming, and deletion", :js, :vcr do
      visit root_path
      expect( page ).to have_content "Start a new plan"
      fill_in 'plan-nearby', with: 'San Francisco'

      wait_for(selector: 'ul.suggested-results li.san-francisco-california-united-states-0')

      within 'ul.suggested-results' do
        first('li').click
      end

      sleep 0.2

      expect( page ).to have_content "Cool! Now Add Places to your List"
      
      # Auto-named the plan
      within '.setplanbox-on-plan-page' do
        expect( page ).to have_content "San Francisco"
        first('i.fa-pencil.rename').click
        fill_in 'rename', with: 'My SF Plan'
      end

      within '.rename-confirmation' do
        first('.planit-button.neon').click
      end

      within '.setplanbox-on-plan-page' do
        expect( page ).to have_content "My SF Plan"
      end

      within '.input-and-results' do
        fill_in 'place-name', with: 'Contigo'
        wait_for(selector: 'ul.suggested-results li.contigo-0')
        within 'ul.suggested-results' do
          first('li.contigo-0').click
        end
      end

      expect( page ).to have_content "ADDING CONTIGO TO YOUR PLAN"

      wait_for(selector: '.plan-list-items')
      contigo = Item.last

      within '.plan-list-items' do
        expect( page ).to have_content "Contigo"
        expect( page ).to have_content "Spanish Restaurant"

        within '.items-organized-by.magenta' do
          expect( page ).to have_content "Food"
        end

        fill_in "item_#{contigo.id}", with: "My favorite local spot"
      end

      expect( full_path ).to include Plan.last.id.to_s

      expect( page ).not_to have_content "See"

      within '.input-and-results' do
        fill_in 'place-name', with: 'Alcatraz'
        wait_for(selector: 'ul.suggested-results li.alcatraz-island-0')
        within 'ul.suggested-results' do
          first('li.alcatraz-island-0').click
        end
      end

      wait_for(selector: '.items-organized-by.green')

      alcatraz = Item.last

      expect( alcatraz ).not_to eq contigo

      within '.items-in-plan' do
        expect( page ).to have_content "See"
        expect( page ).to have_content "Alcatraz Island"
        expect( page ).to have_content "Historic Site"
        fill_in "item_#{alcatraz.id}", with: 'Ai Wei Wei and whatever'
        expect( contigo.notes.first.body ).to eq 'My favorite local spot'
        fill_in "item_#{contigo.id}", with: 'My favorite local spot -- in Noe, where I live'
        sleep 2
      end

      expect( contigo.notes.first.reload.body ).to eq 'My favorite local spot -- in Noe, where I live'
      expect( alcatraz.notes.first.body ).to eq 'Ai Wei Wei and whatever'

      expect( contigo_tab.length ).to eq 1
      expect( ng_shown( root: contigo_tab, selector: 'i.action.fa.fa-heart').length ).to eq 1
      expect( ng_hidden(root: contigo_tab, selector: 'i.action.fa.fa-heart.neon').length ).to eq 1

      expect( contigo.mark.loved ).to eq false
      
      within 'li.plan-list-item.item-li-contigo' do
        first('i.action.fa.fa-heart').click
      end

      sleep 0.5
      expect( ng_shown( root: contigo_tab, selector: 'i.action.fa.fa-heart.neon' ).length ).to eq 1
      expect( ng_shown( root: contigo_tab, selector: 'i.action.fa.fa-heart').length ).to eq 1

      sleep 0.5

      expect( contigo.mark.reload.loved ).to eq true
      expect( contigo.mark.been ).to eq false

      within 'li.plan-list-item.item-li-contigo' do
        first('i.action.fa.fa-check-square').click
      end
      
      sleep 0.5
      expect( contigo.mark.reload.been ).to eq true

      within 'li.plan-list-item.item-li-contigo' do
        first('i.action.fa.fa-trash').click
      end

      page.driver.browser.switch_to.alert.accept

      sleep 0.5
      expect( Item.find_by(id: contigo.id) ).to eq nil

      # BACK TO HOME

      within '.sort-and-view-modes' do
        first('.selectable.sort-by-button').click # My Guides link
      end 

      expect( ['/', '/?'] ).to include full_path

      within '.any-tab-wrapper.my-sf-plan-0' do
        first('.content-tab-img').click
      end

      expect( full_path ).to include Plan.last.id.to_s

      # ONTO MAP
      # TODO class-from-name helper that excludes all weird characters
    end

    def contigo_tab
      Nokogiri.parse(html).css('li.plan-list-item.item-li-contigo')
    end
  end

end