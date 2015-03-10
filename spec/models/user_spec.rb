require 'rails_helper'

describe User do
  describe '#save_as_beta' do
    it "saves the user as pending and shoots off two emails" do
      user = build(:user, password: nil, role: :pending)

      expect(AdminMailer).to receive(:notify_of_signup).at_least(:once).and_call_original
      expect(UserMailer).to receive(:welcome_beta).at_least(:once).and_call_original

      expect{
        user.save_as_beta
      }.to change{ User.count }.by 1
    end
  end
end