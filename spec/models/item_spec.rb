require 'spec_helper'

describe Item do
  describe 'from_flat_hash!' do
    it "turns a flat hash into an item, location, and photo" do
      l_count = Location.count
      i_count = Item.count
      p_count = Image.count

      i = Item.from_flat_hash!(full_params)

      expect(Location.count).to eq(l_count + 1)
      expect(Item.count).to eq(i_count + 1)
      expect(Image.count).to eq(p_count + 1)

      expect(i.location.lat).to be_within(0.001).of(full_params[:lat])
      expect(i.meal).to eq(full_params[:meal])
      expect(i.images.first.url).to eq(full_params[:photo])
    end

    it "doesn't create a blank photo" do
      p_count = Image.count

      i = Item.from_flat_hash!(location_params.merge(item_params))

      expect(Image.count).to eq(p_count)
      expect(i.images).to eq([])
    end

    it "doesn't duplicate locations" do
      l = Location.create!(location_params)
      i = nil # variable scope

      expect{ i = Item.from_flat_hash!(full_params) }.not_to change{ Location.count }

      expect( i.location ).to eq l
    end

    it "does duplicate photos" do
      p = Image.create!(url: photo_params[:photo])
      i = nil # variable scope

      expect{ i = Item.from_flat_hash!(full_params) }.to change{ Image.count }.by(1)

      expect( i.images.first ).not_to eq p
      expect( i.images.first.url ).to eq p.url
    end
  end
end

def full_params
  location_params.merge(photo_params).merge(item_params)
end

def location_params
  {
    lat: 37.74422249388305,
    lon: -122.4352317663816,
    name: "Contigo",
    phone: "4152850250",
    street_address: "1320 Castro St",
    country: "United States",
    state: "CA",
    city: "San Francisco",
  }
end

def photo_params
  { photo: "https://irs3.4sqi.net/img/general/200x200/2261_a2HV5M7fSEIO1oiL0DHbvHMGdJ3xHEozUVUY0U5w0ag.jpg" }
end

def item_params
  {
    category: "Spanish Restaurant",
    meal: true,
    lodging: false
  }
end