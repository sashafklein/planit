require 'spec_helper'

describe PlaceHours do

  before do 
    allow(Timezone::Zone).to receive(:new).and_return( double( zone: "Europe/Paris" ) )
    @comptoir = create(:comptoir)
  end

  describe "#full_hours" do
    it "expands a day's hours to include overlap from the previous" do

      expect( calculator.hours['sat'] ).to match_array([
        {
          'start_time' => '1200',
          'end_time' => '0200'
        }
      ])
      
      expect( calculator.hours['sun'] ).to match_array([
        {
          'start_time' => '1200',
          'end_time' => '0000'
        }
      ])

      expect( calculator.full_hours['sat'] ).to match_array([
        {
          'start_time' => '1200',
          'end_time' => '0200'
        }
      ])

      expect( calculator.full_hours['sun'] ).to match_array([
        {
          'start_time' => '0000',
          'end_time' => '0200'
        },
        {
          'start_time' => '1200',
          'end_time' => '0000'
        }
      ])
    end
  end
  
  describe "#open?, #open_until, and #open_again_at" do

    it "returns false if there are no hours for the day" do
      Timecop.freeze( DateTime.parse('Jan 3 2015 5:30am EST') ) do # 11:30am in Paris, Saturday
        calculator.place.remove_from_hours!('sat')
        expect( calculator.hours['sat'] ).to eq nil
        expect( calculator.open? ).to eq false
      end
    end

    it "returns false if there are hours but we're outside of them" do
      Timecop.freeze( DateTime.parse('Jan 3 2015 5:30am EST') ) do # 11:30am in Paris, Saturday
        expect( calculator.open? ).to eq false
        expect( calculator.open_until ).to eq nil # open two hours later on Saturdays
        expect( calculator.open_again_at ).to eq '1200'
      end
    end

    it "returns true if we're inside the hours" do
      Timecop.freeze( DateTime.parse('Jan 3 2015 6:30am EST') ) do # 12:30pm in Paris, Saturday
        expect( calculator.open? ).to eq true
        expect( calculator.open_until ).to eq '0200' # open two hours later on Saturdays
        expect( calculator.open_again_at ).to eq nil
      end
    end
  end

  def calculator
    PlaceHours.new(@comptoir)
  end
end