require 'spec_helper'

describe FourSquareCompleter do
  describe "complete!" do
    context "with sufficient information" do
      it "completes with latLon and name", :vcr do
        f = FourSquareCompleter.new({lat: 37.74422249388305, lon: -122.4352317663816, name: "Contigo"})
        completed = f.complete!

        expect(completed[:street_address]).to eq('1320 Castro St')
        expect(completed[:category]).to eq('Spanish Restaurant')
        expect(completed[:meal]).to eq true
        expect(completed[:lodging]).to eq false
      end

      it "completes with locality and name", :vcr do
        f = FourSquareCompleter.new({locality: 'Cartagena, Colombia', name: "La Cevicheria"})
        completed = f.complete!

        expect(completed[:photo]).to be_present
        expect(completed[:category]).to eq('Seafood Restaurant')
        expect(completed[:country]).to eq('Colombia')
        expect(completed[:state]).to eq('Bolívar')
      end
    end

    context "with insufficient information" do
      it "returns original without name" do
        f = FourSquareCompleter.new({lat: 37.74422249388305, lon: -122.4352317663816, photo: 'whatever'})
        expect(f.complete!).to eq( {lat: 37.74422249388305, lon: -122.4352317663816, photo: 'whatever'} )
      end

      it "returns original without locality or ll" do
        f = FourSquareCompleter.new({name: "Contigo", street_address: '1320 Castro St'})
        expect(f.complete!).to eq( {name: "Contigo", street_address: '1320 Castro St'} )
      end
    end
  end
end