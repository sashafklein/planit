require 'rails_helper'

describe SharesController do
  describe "create" do
    it "sends off object-specific emails, with multiple recipients allowed" do
      plan = create(:plan, user: create(:user))
      allow_any_instance_of( SharesController ).to receive(:url).and_return( 'wassup.com' )
      sign_in plan.user

      e1 = 'email1@fake.com'
      e2 = 'email2@fake.com'
      e3 = 'email3@fake.com'

      expect( UserMailer ).to receive(:share_plan).at_least(:thrice).and_call_original

      post :create, share: { obj_id: plan.id, obj_type: 'Plan', email: "#{e1},#{e2} #{e3}", notes: 'BaLAM' }

      subj = "A Planit Guide from First Last: Plan name 1"
      expect( delivered_emails.map(&:subject).uniq ).to eq [subj]
      expect( delivered_emails.map(&:to).flatten ).to array_eq [e1, e2, e3]
      expect( email_text(subject: subj) ).to include 'BaLAM'
      expect( email_text(subject: subj) ).to include "http://www.example.com/plans/#{plan.id}"
    end
  end
end