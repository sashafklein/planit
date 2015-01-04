require 'spec_helper'

describe Place, :vcr do 
  describe "#open?, #open_until, and #open_again_at" do

    before do 
      @comptoir = create(:comptoir)
      allow(Timezone::Zone).to receive(:new).and_return double( zone: "Europe/Paris" )
    end

    it "returns nil if there are no hours for the day" do
      Timecop.freeze( DateTime.parse('Jan 3 2015 5:30am EST') ) do # 11:30am in Paris, Saturday
        @comptoir.remove_from_hours!('sat')
        expect( @comptoir.hours['sat'] ).to eq nil
        expect( @comptoir.open? ).to eq nil
      end
    end

    it "returns false if there are hours but we're outside of them" do
      Timecop.freeze( DateTime.parse('Jan 3 2015 5:30am EST') ) do # 11:30am in Paris, Saturday
        expect( @comptoir.open? ).to eq false
        expect( @comptoir.open_until ).to eq nil # open two hours later on Saturdays
        expect( @comptoir.open_again_at ).to eq '1200'
      end
    end

    it "returns true if we're inside the hours" do
      Timecop.freeze( DateTime.parse('Jan 3 2015 6:30am EST') ) do # 12:30pm in Paris, Saturday
        expect( @comptoir.open? ).to eq true
        expect( @comptoir.open_until ).to eq '0200' # open two hours later on Saturdays
        expect( @comptoir.open_again_at ).to eq nil
      end
    end
  end

end