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
        first('li.san-francisco-california-united-states-0').click
      end

      sleep 0.2

      expect( page ).to have_content "YOU'RE THE FIRST PLANITEER"
      
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
        wait_for(selector: 'ul.suggested-results li.contigo')
        within 'ul.suggested-results' do
          first('li.contigo').click
        end
      end

      expect( page ).to have_content "ADDING CONTIGO TO YOUR PLAN"

      wait_for(selector: 'li.plan-list-item')
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
        wait_for(selector: 'ul.suggested-results li.alcatraz-island', limit: 15)
        within 'ul.suggested-results' do
          first('li.alcatraz-island').click
        end
      end

      wait_for(selector: '.items-organized-by.green', limit: 15)

      alcatraz = Item.last

      expect( alcatraz ).not_to eq contigo

      within '.items-in-plan' do
        expect( page ).to have_content "See"
        expect( page ).to have_content "Alcatraz Island"
        expect( page ).to have_content "Historic Site"
        fill_in "item_#{alcatraz.id}", with: 'Ai Wei Wei and whatever'
        expect( contigo.notes.first.body ).to eq 'My favorite local spot'
        fill_in "item_#{contigo.id}", with: 'My favorite local spot -- in Noe, where I live'
        sleep 2.75
      end

      expect( contigo.notes.first.reload.body ).to eq 'My favorite local spot -- in Noe, where I live'
      expect( alcatraz.notes.first.body ).to eq 'Ai Wei Wei and whatever'

      expect( contigo_tab.length ).to eq 1
      expect( ng_shown( root: contigo_tab, selector: 'i.action.fa.fa-heart').length ).to eq 1
      expect( ng_hidden(root: contigo_tab, selector: 'i.action.fa.fa-heart.neon').length ).to eq 0

      expect( contigo.mark.loved ).to eq false
      
      within contigo_selector do
        first('i.action.fa.fa-heart').click
        sleep 0.3
      end

      expect( ng_shown( root: contigo_tab, selector: 'i.action.fa.fa-heart.neon' ).length ).to eq 1
      expect( ng_shown( root: contigo_tab, selector: 'i.action.fa.fa-heart').length ).to eq 2

      expect( contigo.mark.reload.loved ).to eq true
      expect( contigo.mark.been ).to eq false

      within contigo_selector do
        first('i.action.fa.fa-check-square').click
      end
      
      sleep 0.5
      expect( contigo.mark.reload.been ).to eq true

      within contigo_selector do
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

      # CHANGING LOCATION

      within '.reset-location' do
        first('i.fa-times').click
      end

      expect( ng_shown( selector: '.set-location-reminder').length ).to eq 1
      
      within '.input-and-results' do
        fill_in 'place-nearby', with: "Oakland, CA"  
      end

      wait_for(selector: 'ul.suggested-results li.oakland-california-united-states-0')

      first('ul.suggested-results li.oakland-california-united-states-0').click
      
      fill_in 'place-name', with: 'Camino'

      within 'ul.suggested-results' do
        wait_for(selector: 'li.camino')
        first('li.camino').click
      end

      wait_for(selector: '.item-li-camino-0')

      within 'li.item-li-camino-0' do
        expect( page ).to have_content 'Oakland, California'
      end

      # ONTO MAP
      expect( full_path ).not_to include 'mode=map'

      within '.view-and-edit-mode' do
        first('.map-toggle-button').click
      end
      
      expect( full_path ).to include 'mode=map'

      # Map icon/li tethering
      within '.plan-map-container' do
        icon = ".leaflet-map-pane .leaflet-marker-pane .leaflet-marker-icon[title='Camino'] .default-map-icon-tab"
        wait_for(selector: icon)
        expect( classes_for(icon) ).not_to include 'highlighted'
        find('.bucket-list-li.camino-0').hover
        expect( classes_for(icon) ).to include 'highlighted'
      end

      within '.view-and-edit-mode' do
        first('.list-toggle-button').click
      end
      
      expect( full_path ).to include 'mode=list'
      
      # Sharing Modal

      within '.setplanbox-on-plan-page' do
        first('.fa-cog.settings').click
      end

      within '.settingsbox-on-plan-page' do
        first('.share-plan-settings-link').click
      end

      within '#planit-modal-share' do
        fill_in 'share_email', with: 'fake@email.com'
        fill_in 'share_notes', with: 'This is an awesome plan!'
        first('#planit-modal-submit-share').click
      end

      sleep 1

      expect( delivered_emails.count ).to eq 1
      subject = "A Planit Guide from #{@user.name}: My SF Plan!"
      text = email_text(subject: subject)
      expect( text ).to include("This is an awesome plan!")
      expect( text ).to include("Ai Wei Wei and whatever")
      expect( email_by_subject(subject).to ).to eq ['fake@email.com']

      # Copying Plan

      within '.setplanbox-on-plan-page' do
        first('.fa-cog.settings').click
      end

      name = "Copy of 'My SF Plan!' by #{@user.name}"

      expect( Plan.where(name: name).count ).to eq 0
      first('.planit-dropdown-menu.copy-plan-link').click
      
      sleep 0.5
      wait_for(selector: '.settingsbox-on-plan-page')

      expect( Plan.where(name: name).count ).to eq 1
      expect( full_path ).to include( Plan.find_by(name: "Copy of 'My SF Plan!' by #{@user.name}").id.to_s )

      # Delete

      within '.setplanbox-on-plan-page' do
        first('.fa-cog.settings').click
      end

      first('.planit-dropdown-menu.delete-plan-link').click
      page.driver.browser.switch_to.alert.accept

      sleep 0.5

      expect( ['/', '/?'] ).to include full_path

      expect( Nokogiri.parse(html).css('.content-tab-title').count ).to eq 1
      expect( Plan.count ).to eq 1

      within '.content-tab-title' do
        expect( page ).to have_content "My SF Plan!"
      end
    end

    def contigo_selector
      'li.plan-list-item.item-li-contigo-0'
    end

    def contigo_tab
      Nokogiri.parse(html).css(contigo_selector)
    end
  end

end