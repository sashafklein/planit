require 'rails_helper'

describe MailListEmail do
  describe "waitlist!" do
    it "adds someone to the list and sends them a welcome email" do
      params = build(:user).atts(:email, :first_name, :last_name).to_h
      expect( UserMailer ).to receive(:welcome_waitlist).with(params).at_least(:once).and_call_original

      expect{
        MailListEmail.waitlist!(params)
      }.to change{ MailListEmail.where(params).count }.by 1
    end
  end
end