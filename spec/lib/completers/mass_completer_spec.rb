require 'rails_helper'

module Completers
  describe MassCompleter, :vcr do
    
    include ScraperHelper

    before do 
      @base_name = 'cartagena'
      @base_domain = 'nytimes'
      @expectations = expectations
    end

    describe "given a monstrosity of data" do

      let(:user) { create(:user) }

      it "sequences NYT Amelia Island" do
        return_hash = YAML.load_file(File.join(Rails.root, 'spec', 'support', 'pages', 'nytimes', 'amelia-island.yml'))
        url = 'http://www.nytimes.com/2003/12/12/travel/journeys-36-hours-amelia-island-fla.html?pagewanted=all'
        marks = MassCompleter.new(return_hash, user, url).complete!

        expect( marks.all?{ |m| m.is_a? Mark } ).to eq true

        expect( marks.map(&:place).map(&:scrape_url).all?{ |url| url == url } ).to eq true
        plans = marks.map{ |m| m.items.first }.map{ |i| i.plan }.uniq
        expect( plans.count ).to eq( 1 )
        plan = plans.first
        expect( plan.name ).to eq "36 Hours  -  Amelia Island, Fla."

        fhi = Place.with_name("Florida House Inn").first
        expect( fhi.names ).to include('1857 Florida House Inn')
        expect( fhi.street_addresses ).to eq ["22 South Third Street", '20 South 3rd Street']
        expect( fhi.phones ).to eq( ["9042613300"] )
        expect( fhi.extra ).to hash_eq( { section_title: "Boardinghouse Brunch" } )
        
        expect( fhi.foursquare_id ).to eq "4bc44ea1dce4eee17915729d"
        expect( fhi.locality ).to sorta_eq( 'Amelia Island' )
        expect( fhi.subregion ).to sorta_eq( 'Nassau County' )
        expect( fhi.region ).to sorta_eq( 'Florida' )

        plan_source = plans.first.sources.first
        expect( plan_source.name ).to eq 'New York Times'
        expect( plan_source.full_url ).to eq url
        expect( plan_source.base_url ).to eq "http://www.nytimes.com"

        mark = user.marks.find_by( place_id: fhi.id )
        expect( mark.items.count ).to eq 1
        item = plan.items.find_by( mark: mark )

        expect( item.start_time ).to eq '11 a.m.'

        expect( item.notes.first.body ).to eq "The dining rooms at the Florida House Inn (22 South Third Street, 904-261-3300) are covered with chickens -- paintings, signs, weather vanes -- and they are the main event on the menu, too."
        expect( item.notes.first.source.full_url ).to eq url

        expect( plan.locations.pluck(:ascii_name) ).to include "Nassau County"

        mark_count = Mark.count
        plan_count = Plan.count
        source_count = Source.count
        note_count = Note.count
        
        # Scraping the same page twice just returns your previous plan's marks
        new_marks = MassCompleter.new(return_hash, user, url).complete! 
        
        expect( plan_count ).to eq Plan.count
        expect( mark_count ).to eq Mark.count
        expect( source_count ).to eq Source.count
        expect( note_count ).to eq Note.count
        expect( new_marks.to_a ).to array_eq marks
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
    end
  end
end