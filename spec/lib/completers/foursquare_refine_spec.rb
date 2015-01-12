require 'spec_helper'

module Completers
  describe FoursquareRefine do

    describe "the new attributes" do

      it "grabs all the necessary information from Lavash" do
        pip = PlaceInProgress.new({foursquare_id: '49b3268cf964a520e1521fe3' })
        pip = FoursquareRefine.new(pip).complete[:place]
        
        expect( pip.reservations ).to eq true
        expect( pip.reservations_link ).to eq nil
        expect( pip.hours ).to hash_eq({
          "tue"=>[["1130", "1500"], ["1700", "2200"]],
          "wed"=>[["1130", "1500"], ["1700", "2200"]],
          "thu"=>[["1130", "1500"], ["1700", "2200"]],
          "fri"=>[["1130", "1500"], ["1700", "2200"]],
          "sat"=>[["1130", "2200"]],
          "sun"=>[["1200", "2100"]]
        })
        
        expect( pip.cross_street ).to eq "at 6th St"
        expect( pip.wifi ).to eq false
        expect( pip.menu ).to eq "https://foursquare.com/v/lavash/49b3268cf964a520e1521fe3/menu"
        expect( pip.mobile_menu ).to eq "https://foursquare.com/v/49b3268cf964a520e1521fe3/device_menu"
        expect( pip.flags ).to eq []
        expect( pip.completion_steps ).to eq ['FoursquareRefine']
      end
    end
  end
end