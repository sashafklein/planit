require "rails_helper"

describe "Invitation Flow" do

  context "without an extant user" do
    it "takes an invited user through password-changing to the root path" do
      expect( UserMailer ).to receive(:welcome_invited).at_least(:once).and_call_original

      user = build(:user, password: nil, password_confirmation: nil).save_as(:member)
      
      visit invite_link

      expect( current_path ).to eq edit_user_password_path

      new_pass = 'myNewPassword'

      within '.simple-entry-form' do
        fill_in "user_password", with: new_pass
        fill_in "user_password_confirmation", with: new_pass
        click_button 'Change'
      end

      expect( current_path ).to eq root_path
      expect( page ).to have_content "#{user.first_name}'s Planit"
      expect( user.reload.valid_password?(new_pass) ).to eq true
    end
  end

  context "with an extant user" do
    it "finds the user and doesn't change their password" do
      expect( UserMailer ).to receive(:welcome_invited).at_least(:twice).and_call_original

      user = create(:user, role: :pending, sign_in_count: 1)
      user.save_as(:member)
      visit invite_link

      expect( current_path ).to eq new_user_session_path
    end

    it "doesn't send a message to an existing member" do
      expect( UserMailer ).not_to receive(:welcome_invited)

      user = create(:user, role: :member, sign_in_count: 1)
      user.save_as(:member)
    end
  end

  context "sending an invite" do
    it "allows a message to be sent off" do
      expect( UserMailer ).to receive(:welcome_invited).at_least(:once).and_call_original

      user = create(:user, role: :member)
      sign_in user
      visit invite_path

      fill_in :user_first_name, with: 'Blank'
      fill_in :user_last_name, with: 'Other'
      fill_in :user_email, with: 'fake@email.com'

      expect{ click_button('Share the Love!') }.to change{
        User.where(first_name: 'Blank', last_name: 'Other', email: 'fake@email.com').count
      }.by 1
    end
  end

  def invite_link
    welcome_email = ActionMailer::Base.deliveries.find{ |d| d.subject == "Welcome to Planit Beta!" }
    email_text = welcome_email.parts.first.body.raw_source
    Nokogiri.parse(email_text).css('.invite-link').first.attributes['href'].value.gsub('http://www.example.com', '')
  end
end