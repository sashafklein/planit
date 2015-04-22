require "rails_helper"

describe "Invitation/New Sign in Flow" do

  before do 
    @params = { first_name: 'First', last_name: 'Last', email: 'email@fake.com' }.to_sh
  end

  context "visiting beta" do
    
    it "as an existing user - does nothing but flashes" do
      user = create(:user, @params.to_h)
      fill_in_form

      expect( MailListEmail.count ).to eq 1
      expect{ click_button 'Sign up' }.not_to change{ User.count }
      expect( MailListEmail.count ).to eq 1

      expect( current_path ).to eq new_user_session_path
      expect_flash "#{user.first_name} is already a Planit member!"
    end 

    it "as a n00b - saves the email to the list but doesn't create a user" do
      fill_in_form
      
      expect{ 
        click_button 'Sign up'
      }.to change{ MailListEmail.where(@params).count }.by 1

      expect( current_path ).to eq beta_path
      expect_flash "Great! We'll be in touch shortly"
      expect( User.count ).to eq 0
    end

    it "as an accepted email - redirects to registration" do
      email = AcceptedEmail.create!(email: @params.email)
      
      fill_in_form
      
      click_button 'Sign up'
      expect( MailListEmail.where(@params).count ).to eq 0

      expect( current_path ).to eq new_user_registration_path #(@params)
      expect_flash "You're on the accepted emails list! Create an account to sign in"

      fill_in :user_password, with: 'Password'
      fill_in :user_password_confirmation, with: 'Password'
      
      expect{ 
        click_button "Sign up"
      }.to change{ User.where( @params.merge(role: 1) ).count }.by 1

      expect_flash "Welcome! You have signed up successfully."
      expect( MailListEmail.where(@params).count ).to eq 1
    end

  end

  context "visiting registration directly" do
    it "with email in accepted list - registers successfully" do
      email = AcceptedEmail.create!(email: @params.email)

      visit new_user_registration_path
      fill_in_form(true)

      expect{ 
        click_button 'Sign up'
      }.to change{ User.where( @params.merge(role: 1) ).count }.by 1
    end

    it "without email in accepted list - saves new email and flashes" do
      visit new_user_registration_path
      fill_in_form(true)

      expect{ 
        click_button 'Sign up'
      }.to change{ MailListEmail.where( @params ).count }.by 1
      expect( User.count ).to eq 0

      expect_flash "Planit is in private beta. We'll get back in touch shortly"
    end
  end

  context "inviting a user" do
    it "sends out an email from the invite page, and creates an accepted_email" do
      expect( UserMailer ).to receive(:welcome_invited).at_least(:once).and_call_original
      sign_in create(:user)
      expect( User.count ).to eq 1

      visit invite_path

      fill_in_form
      expect{ 
        click_button 'Share the Love!'
      }.to change{ AcceptedEmail.where(email: @params.email).count }.by(1)
      
      expect( User.count ).to eq 1
      expect( invite_link ).to eq new_user_registration_path(@params)
    end

    it "errors without an email filled out" do
      expect( UserMailer ).not_to receive(:welcome_invited)
      sign_in create(:user)
      expect( User.count ).to eq 1

      visit invite_path

      fill_in :user_first_name, with: @params.first_name
      fill_in :user_last_name, with: @params.last_name
      fill_in :user_email, with: 'Bullshit'

      expect{
        click_button 'Share the Love!'
      }.not_to change{ AcceptedEmail.where(email: @params.email).count }

      expect( current_path ).to eq invite_path
      expect_flash "Please enter a valid email address"
    end

    it "alerts if the user already exists" do
      user2 = create(:user, @params.to_h)
      sign_in create(:user)

      visit invite_path

      fill_in_form
      expect{ 
        click_button "Share the Love!"
      }.not_to change{ User.count }

      expect_flash "#{user2.first_name} is already a Planit member!"
    end
  end

  describe "referral redirect flow" do

    before { @plan = create(:plan) }

    it "redirects existing users to sign_in, then back to where they were headed" do
      user = create(:user)
      visit plans_path(plan: @plan.id, referred: 'registered', email: user.email)

      expect( full_path ).to eq new_user_session_path(email: user.email)
      fill_in :user_password, with: 'password'
      click_button 'Sign in'

      expect( full_path ).to eq plans_path(plan: @plan.id)
    end

    it "redirects new users to registration, then back where they were headed" do
      sharer = create(:user)
      user = build(:user)

      Share.save_and_send(sharer: sharer, sharee: user, url: plans_url(plan: @plan.id), notes: 'Yeah!')

      text = email_text(subject: "A Planit Guide from #{sharer.name}: #{@plan.name}")

      link = Nokogiri.parse(text).css('a')[2].attributes['href']

      visit link

      expect( full_path ).to eq new_user_registration_path(email: user.email)
      fill_in_form true, [:email]

      share = Share.find_by(sharer: sharer, url: plans_url(plan: @plan.id), notes: 'Yeah!')
      expect( share.reload.sharee ).to be_nil

      expect( MailListEmail.find_by(email: user.email) ).to be_nil
      click_button 'Sign up'
      expect( MailListEmail.find_by(email: user.email) ).to be_present

      new_user = User.where( user.atts(:email, :first_name, :last_name) ).first
      expect( share.reload.sharee ).to eq new_user
      expect( full_path ).to eq plans_path(plan: @plan.id)
    end
  end

  def invite_link
    Nokogiri.parse(email_text).css('.invite-link').first.attributes['href'].value.gsub('http://www.example.com', '')
  end

  def fill_in_form(registering=false, skip=[])
    visit beta_path unless registering
    fill_in :user_first_name, with: @params.first_name unless skip.include?( :first_name )
    fill_in :user_last_name, with: @params.last_name unless skip.include?( :last_name )
    fill_in :user_email, with: @params.email unless skip.include?( :email )
    if registering
      fill_in :user_password, with: 'password'
      fill_in :user_password_confirmation, with: 'password'
    end
  end
end