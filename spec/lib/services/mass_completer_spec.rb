require 'spec_helper'

module Services
  describe MassCompleter do

    include ScraperHelper

    before do 
      @base_name = 'cartagena'
      @base_domain = 'nytimes'
      @expectations = expectations
    end

    describe "complete!" do
      it 'delegates to an individual completer for each item' do
        allow(Completer).to receive(:new) { double(complete!: 'completed!') }
        @mass_completer = MassCompleter.new(@expectations, 'user')
        completions = @mass_completer.complete!
        
        expect(completions.all? { |c| c == 'completed!' } ).to eq true
        expect(completions.length).to eq(@expectations.length)
      end
    end

    describe "given a monstrosity of data" do

      let(:user) { create(:user) }

      it "sequences NYT Amelia Island", :vcr do
        return_hash = YAML.load_file(File.join(Rails.root, 'spec', 'support', 'pages', 'nytimes', 'amelia-island.yml'))

        marks = MassCompleter.new(return_hash, user).complete!

        expect( marks.all?{ |m| m.is_a? Mark } ).to eq true

        plans = marks.map{ |m| m.items.first }.map{ |i| i.plan }.uniq
        expect( plans.count ).to eq( 1 )
        expect( plans.first.name ).to eq "JOURNEYS -  36 Hours  -  Amelia Island, Fla. - NYTimes.com"

        florida_house_inn = Place.with_name("Florida House Inn").first
        expect( florida_house_inn.names ).to include('1857 Florida House Inn')
        expect( florida_house_inn.street_addresses ).to eq ["22 South Third Street", '20 S 3rd St']
        expect( florida_house_inn.phones ).to eq( { 'default' => "904-261-3300" } )
        expect( florida_house_inn.extra ).to eq( { 'section_title' => "Boardinghouse Brunch" } )
        
        expect( florida_house_inn.locality ).to eq( 'Fernandina Beach' )
        expect( florida_house_inn.subregion ).to eq( 'Nassau County' )
        expect( florida_house_inn.region ).to eq( 'Florida' )
        # expect( florida_house_inn.sources.count ).to eq 1
        # expect( florida_house_inn.sources.name ).to eq "New York Times"
        # expect( florida_house_inn.sources.note.first(10) ).to eq "The dining"

        mark = user.marks.find_by_place_id( florida_house_inn.id )
        expect( mark.items.count ).to eq 1
        item = mark.items.first

        expect( item.plan ).to eq plans.first
        expect( item.day.order ).to eq 3

        expect( item.order ).to eq 11
        expect( item.start_time ).to eq '11:00'
        expect( item.sunday? ).to eq true
      end

      it "sequences TripAdvisor Bogota" do
      end
    end
  end
end