require 'rails_helper'

module Completers
  describe ExistingPlaceCompleter, :vcr do

    describe "complete!" do

      before do 
        @place = create(:comptoir, locality: nil, region: nil, country: nil, street_addresses: [])
      end

      it "takes a named 'delay' argument (default true)" do
        expect( DelayExistingPlaceCompleteJob ).to receive(:perform_later).with(@place.id).twice

        ExistingPlaceCompleter.new(@place).complete!
        ExistingPlaceCompleter.new(@place).complete!(delay: true)
      end

      it "executes immediately without the delay" do
        expect_any_instance_of( ExistingPlaceCompleter ).to receive(:complete!).with(delay: false).and_call_original
        @place.complete!(delay: false)
        expect( @place.reload.country ).to eq 'France'
        expect( @place.reload.locality ).to eq 'Paris'
        expect( @place.street_address ).to sorta_eq "9 carrefour de l'Odéon"
      end
    end

  end
end