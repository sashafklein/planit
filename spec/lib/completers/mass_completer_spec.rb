require 'rails_helper'

module Completers
  xdescribe MassCompleter, :vcr do
    
    include ScraperHelper

    before do 
      @base_name = 'cartagena'
      @base_domain = 'nytimes'
      @expectations = expectations
    end

    describe "complete!" do
      it 'delegates to an individual completer for each item' do
        allow(Completer).to receive(:new) { double(complete!: 'completed!') }

        @mass_completer = MassCompleter.new(@expectations, 'user', 'http://www.nytimes.com/2014/09/14/travel/things-to-do-in-36-hours-in-cartagena-colombia.html?_r=0')
        completions = @mass_completer.complete!
        
        expect(completions.all? { |c| c == 'completed!' } ).to eq true
        expect(completions.length).to eq(@expectations.length)
      end
    end

    describe "given a monstrosity of data" do

      let(:user) { create(:user) }

      it "sequences NYT Amelia Island" do
        return_hash = YAML.load_file(File.join(Rails.root, 'spec', 'support', 'pages', 'nytimes', 'amelia-island.yml'))

        marks = MassCompleter.new(return_hash, user, 'http://www.nytimes.com/2003/12/12/travel/journeys-36-hours-amelia-island-fla.html?pagewanted=all').complete!

        expect( marks.all?{ |m| m.is_a? Mark } ).to eq true

        expect( marks.map(&:place).map(&:scrape_url).all?{ |url| url == 'http://www.nytimes.com/2003/12/12/travel/journeys-36-hours-amelia-island-fla.html?pagewanted=all' } ).to eq true
        plans = marks.map{ |m| m.items.first }.map{ |i| i.plan }.uniq
        expect( plans.count ).to eq( 1 )
        expect( plans.first.name ).to eq "36 Hours  -  Amelia Island, Fla."

        florida_house_inn = Place.with_name("Florida House Inn").first
        expect( florida_house_inn.names ).to include('1857 Florida House Inn')
        expect( florida_house_inn.street_addresses ).to eq ["22 South Third Street", '20 South 3rd Street']
        expect( florida_house_inn.phones ).to eq( ["9042613300"] )
        expect( florida_house_inn.extra ).to hash_eq( { section_title: "Boardinghouse Brunch" } )
        
        expect( florida_house_inn.foursquare_id ).to eq "4bc44ea1dce4eee17915729d"
        expect( florida_house_inn.locality ).to sorta_eq( 'Amelia Island' )
        expect( florida_house_inn.subregion ).to sorta_eq( 'Nassau County' )
        expect( florida_house_inn.region ).to sorta_eq( 'Florida' )

        # expect( florida_house_inn.sources.count ).to eq 1
        # expect( florida_house_inn.sources.name ).to eq "New York Times"
        # expect( florida_house_inn.sources.note.first(10) ).to eq "The dining"

        mark = user.marks.find_by_place_id( florida_house_inn.id )
        expect( mark.items.count ).to eq 1
        item = mark.items.first

        expect( item.plan ).to eq plans.first

        expect( item.start_time ).to eq '1100'
        expect( item.sunday? ).to eq true
      end

      it "gets the frommers Three days in Rome shit" do
        url = 'http://www.frommers.com/destinations/rome/705674'
        yamlator = HtmlToYaml.new( end_path: 'frommers/threedays', url: url)
        marks = MassCompleter.new(yamlator.data, user, url).complete!
        expect( marks.count ).to eq yamlator.data.count
        expect( marks.map(&:place).map(&:country).uniq ).to eq ['Italy']
      end

      it "errors without a url" do
        expect{ MassCompleter.new(return_hash, user) }.to raise_error
      end

      it "sequences TripAdvisor Bogota" do
      end
    end
  end
end