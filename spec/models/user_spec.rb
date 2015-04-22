require 'rails_helper'

describe User do
  describe "invite!" do
    it "saves the email to the acceptable list and shoots off an email" do
      user = build(:user)
      expect( UserMailer ).to receive(:welcome_invited).at_least(:once).with(user.atts(:email, :first_name, :last_name)).and_call_original
      
      expect{
        user.invite!
      }.to change{ AcceptedEmail.where(email: user.email).count }.by 1
    end
  end
end