require 'spec_helper'
 
describe Api::V1::AllowableSitesController do
  describe 'test' do
 
    it 'returns success for insta-scrapable sites' do
      allowable = [
        "http://www.nytimes.com/whatever",
        "tripadvisor.it/whatever",
        "stay.com",
        "www.gayot.co.uk",
        "https://maps.google.com/?q=ejfijeofij",
        "https://www.google.com/maps/place/Bar+Harbor,+ME/@44.3760249,-68.2866853,12z/data=!3m1!4b1!4m2!3m1!1s0x4caebe4815802593:0x88e91a6528cad91b",
      ]
      allowable.each do |site|
        get :test, url: site
        expect( response_body[:success] ).to eq true
      end
    end
 
    it 'errors for unacceptable sites' do
      unallowable = [
        "www.nikoklein.com",
        "https://gist.github.com/sashafklein/c45300506652b32b4b1e",
        "http://stackoverflow.com/questions/3829150/google-chrome-extension-console-log-from-background-page",
        "https://mail.google.com/mail/u/0/#inbox",
        "chrome://extensions/",
        "https://devcenter.heroku.com/articles/git-repository-ssh-fingerprints",
      ]
      unallowable.each do |site|
        get :test, url: site
        expect( response_body[:error] ).to eq true
      end
    end

  end
end
