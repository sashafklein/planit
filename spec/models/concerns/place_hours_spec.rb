require 'spec_helper'

describe PlaceHours do

  before do 
    @comptoir = create(:comptoir)
  end

  describe "#hours and #bands" do
    it "expands a day's hours to include overlap from the previous" do

      expect( @comptoir.hours['sat'] ).to match_array([
        {
          'start_time' => '1200',
          'end_time' => '0200'
        }
      ])
      
      expect( @comptoir.hours['sun'] ).to match_array([
        {
          'start_time' => '1200',
          'end_time' => '0000'
        }
      ])

      expect( calculator.hours['sat'] ).to match_array([ ['1200', '0200'] ])
      expect( calculator.hours['sun'] ).to match_array([ ['0000', '0200'], ['1200', '2400'] ])
      expect( calculator.bands['sat'] ).to eq([ 12.0..26.0 ])
      expect( calculator.bands['sun'] ).to eq([ 0.0..2.0, 12.0..24.0 ])
    end
  end
  
  describe "#open?, #open_until, and #open_again_at" do

    it "returns false if there are no hours for the day" do
      freeze( ('Jan 3 2015 5:30am EST') ) do # 11:30am in Paris, Saturday
        calc = calculator(@comptoir.hours.except('sat'))
        assert_time(calc, '11:30')
        expect( calc.hours['sat'] ).to eq nil
        expect( calc.open? ).to eq false
      end
    end

    it "returns false if there are hours but we're outside of them" do
      freeze( ('Jan 3 2015 5:30am EST') ) do # 11:30am in Paris, Saturday
        assert_time(calculator, '11:30')
        expect( calculator.open? ).to eq false
        expect( calculator.open_until ).to eq nil # open two hours later on Saturdays
        expect( calculator.open_again_at ).to hash_eq({ time: '1200', day: 'sat' })
      end
    end

    it "returns true if we're inside the hours" do
      freeze( ('Jan 3 2015 6:30am EST') ) do # 12:30pm in Paris, Saturday
        assert_time(calculator, '12:30')
        expect( calculator.open? ).to eq true
        expect( calculator.open_until ).to hash_eq({ time: '0200', day: 'sun' })
        expect( calculator.open_again_at ).to eq nil
      end
    end

    it "handles a 24-h place" do
      calc = calculator( @comptoir.hours.merge({ sat: { start_time: '0000', end_time: '0000' } }) )

      freeze( ('Jan 2 2015 6:00pm EST') ) do # 12:00am in Paris, Saturday
        assert_time(calc, '00:00')
        expect( calc.open? ).to eq true
      end

      freeze( ('Jan 2 2015 6:01pm EST') ) do # 12:01am in Paris, Saturday
        assert_time(calc, '00:01')
        expect( calc.open? ).to eq true
      end

      freeze( ('Jan 3 2015 5:59pm EST') ) do # 11:59pm in Paris, Saturday
        assert_time(calc, '23:59')
        expect( calc.open? ).to eq true
      end

      freeze( ('Jan 3 2015 6:00pm EST') ) do # 12:00am in Paris, Sunday
        assert_time(calc, '00:00')
        expect( calc.open? ).to eq false
      end
    end
  end

  def calculator(hours=@comptoir.hours)
    PlaceHours.new(hours, "Europe/Paris")
  end

  def freeze(time_string, &block)
    Timecop.freeze( DateTime.parse(time_string), &block )
  end

  def assert_time(calc, string)
    expect( calc.current_time.strftime("%H:%M") ).to eq string
  end
end