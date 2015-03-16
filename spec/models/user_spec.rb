require 'rails_helper'

describe User do
  describe '#save_as' do
    it "upgrades invited betalistee from pending member" do
      user = build(:user, password: nil, role: :pending)

      expect{
        user.save_as(:member)
      }.to change{ user.role }.to 'member'
    end

    it "successfully generates new password for fresh invitee" do
      user = build(:user, password: nil, role: :pending)
      expect{
        user.save_as(:member)
      }.to change{ User.count }.by 1
    end

    it "successfully builds password for invitee" do
      user = build(:user, password: nil, role: :pending)
      expect{
        user.save_as(:member)
      }.to change{ user.password }
    end

    it "waitlist saves the user as pending and shoots off two emails" do
      user = build(:user, password: nil, role: :pending)

      expect(AdminMailer).to receive(:notify_of_signup).at_least(:once).and_call_original
      expect(UserMailer).to receive(:welcome_waitlist).at_least(:once).and_call_original

      expect{
        user.save_as(:pending)
      }.to change{ User.count }.by 1
    end

    it "invite saves the user as pending and shoots off two emails" do
      user = build(:user, password: nil, role: :pending)

      expect(AdminMailer).to receive(:notify_of_signup).at_least(:once).and_call_original
      expect(UserMailer).to receive(:welcome_invited).at_least(:once).and_call_original

      expect{
        user.save_as(:member)
      }.to change{ User.count }.by 1
    end
  end
end