require 'rails_helper'

describe Share do
  describe "click share" do
    before do
      @sharer = create(:user, role: :member)
      @notes = "Dude this is AMAZING"
    end

    it "sharing user guides shoots off an email" do
      sharee = create(:user, role: :member)
      url = "https://plan.it/users/#{@sharer.slug}/guides?y=in_2015+in_2014"
      object = User.find(@sharer.id)

      expect(UserMailer).to receive(:share_love).at_least(:once).and_call_original

      expect{
        Share.save_and_send(sharer: @sharer, sharee: sharee, url: url, object: object, notes: @notes)
      }.to change{ Share.count }.by 1
    end

    it "sharing user places shoots off an email" do
      sharee = create(:user, role: :member)
      url = "https://plan.it/users/#{@sharer.slug}/guides?y=in_2015+in_2014"
      object = User.find(@sharer.id)

      expect(UserMailer).to receive(:share_love).at_least(:once).and_call_original

      expect{
        Share.save_and_send(sharer: @sharer, sharee: sharee, url: url, object: object, notes: @notes)
      }.to change{ Share.count }.by 1
    end

  end
end

