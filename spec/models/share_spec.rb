require 'rails_helper'

describe Share do
  describe "click share" do
    before do
      @sharer = create(:user, role: :member)
      @notes = "Dude this is AMAZING"
    end

    context "with preexisting user" do
      xit "sharing user guides shoots off an email" do
        sharee = create(:user, role: :member)
        url = "https://plan.it/users/#{@sharer.slug}/guides?y=in_2015+in_2014"
        object = User.find(@sharer.id)

        expect(UserMailer).to receive(:share_love).at_least(:once).and_call_original

        expect{
          @share = Share.save_and_send(sharer: @sharer, sharee: sharee, url: url, obj: object, notes: @notes)
        }.to change{ Share.count }.by 1

        text = email_text(subject: "#{@sharer.name} shared a page on Planit: 2015 2014 Guides" )
        expect( text ).to include 'Dude this is AMAZING'
        expect( text ).to include "https://plan.it/users/#{@sharer.slug}/guides?y=in_2015+in_2014&amp;referred=registered&amp;email=#{sharee.email}&amp;share_id=#{@share.id}"
      end
    end

    context "without a preexising user" do
      it "adds them to the email list and sends them an email that sends them on a good redirection flow" do
        expect( UserMailer ).to receive(:share_plan).at_least(:once).and_call_original

        plan = create(:plan, user: @sharer)
        url = "https://plan.it/?plan=#{plan.id}"
        sharee = build(:user)

        expect( Share.count ).to eq 0
        expect{
          @share = Share.save_and_send(sharer: @sharer, sharee: sharee, url: url, notes: @notes)
        }.to change{ AcceptedEmail.count }.by 1
        expect( Share.count ).to eq 1

        text = email_text(subject: "A Planit Guide from #{@sharer.name}: #{plan.name}" )
        expect( text ).to include "Dude this is AMAZING"
        expect( text ).to include "http://www.example.com/plans/#{plan.id}?email=#{ sharee.email.gsub('@','%40') }&amp;referred=new&amp;share_id=#{@share.id}"
      end
    end

  end
end

