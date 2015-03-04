require 'rails_helper'

describe SourceParser do 
  
  describe "trimmed" do
    it "gets rid of all unnecessary querystring stuff" do
      expect( parser(query: 'blah=bullshit').trimmed ).to eq "http://www.nytimes.com/2010/07/04/travel/04hours.html"
    end

    it "keeps the good stuff" do
      expect( parser.trimmed ).to eq "http://www.nytimes.com/2010/07/04/travel/04hours.html?pagewanted=all"
      expect( parser(query: 'r=bullshit&code=keep_it&q=keep_it&tea=dont' ).trimmed ).to eq "http://www.nytimes.com/2010/07/04/travel/04hours.html?code=keep_it&q=keep_it"
    end
  end

  describe "base" do
    it "parses down to the root domain" do
      expect( parser.base ).to eq 'http://www.nytimes.com'
    end
  end

  describe "name" do
    it "finds the name by domain if it's there" do
      expect( parser.name ).to eq 'New York Times'
    end

    it "falls back to the domain if not" do
      expect( parser(base: "http://www.nytime.com/whatever").name ).to eq "Nytime"
    end
  end

  describe "with a fake url ('email.com' or 'kml.com')" do
    it "ignores all the content and comes up with specialized set of values" do
      p = parser(base: 'http://www.kml.com')
      expect( p.name ).to eq 'KML'
      expect( p.trimmed ).to eq 'KML'
      expect( p.full ).to eq 'KML'
      expect( p.base ).to eq 'KML'

      p2 = parser(base: 'https://www.email.com')
      expect( p2.name ).to eq 'Email'
      expect( p2.trimmed ).to eq 'Email'
      expect( p2.full ).to eq 'Email'
      expect( p2.base ).to eq 'Email'
    end
  end

  describe "tricky stuff" do
    it "handles a naked url" do
      parser = SourceParser.new("http://softwareas.com/injecting-html-into-an-iframe/")
      expect( parser.name ).to eq 'Softwareas'
    end
  end

  def parser(base: nil, query: nil)
    base ||= "http://www.nytimes.com/2010/07/04/travel/04hours.html"
    query ||= "pagewanted=all&_r=0"
    SourceParser.new [base, query].join("?") 
  end
end