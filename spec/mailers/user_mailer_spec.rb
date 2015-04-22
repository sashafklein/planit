require 'rails_helper'

describe UserMailer do 
  describe "secret BCC" do
    it "sends off a BCC of all user_mailer emails" do
      
      class UserMailer
        def bullshit_email_method
          roadie_mail(to: 'bullshit@bullshit.com', body: 'Whatevs', content_type: "text/html", subject: 'Bullshit')
        end
      end

      expect( ActionMailer::Base.deliveries.count ).to eq 0
      expect( UserMailer.respond_to?(:bullshit_email_method) ).to eq true
      UserMailer.bullshit_email_method.deliver_now

      sent = ActionMailer::Base.deliveries.first
      expect( sent.bcc.first ).to eq "sent@plan.it"
      expect( sent.from.first ).to eq "hello@plan.it"
      expect( sent.subject ).to eq 'Bullshit'
    end
  end
end