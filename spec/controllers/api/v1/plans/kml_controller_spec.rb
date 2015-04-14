require 'rails_helper'

describe Api::V1::Plans::KmlController, :vcr do

  describe "index" do

    before do
      @user = create(:user)
      @plan = create(:plan, {user: @user})
      @place = create(:place)
      @mark = create(:mark, place_id: @place.id)
      @item = create(:item, { plan_id: @plan.id, mark_id: @mark.id } )
    end

    # it "requires a user" do
    #   get :index

    #   expect(response.status).to eq(403)
    # end

    it "creates a kml file" do
      sign_in @user      
      get :index, { plan_id: @plan.id }

      # expect(response.body).to contain("""<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<kml xmlns=\"http://earth.google.com/kml/2.1\">\n  <Folder>\n    <name>Plan name 1</name>\n    <Placemark>\n      <name>Place Name 1</name>\n      <description>\n        <![CDATA[/places/50]]>\n      </description>\n      <Point>\n        <coordinates>1.5,1.5</coordinates>\n      </Point>\n    </Placemark>\n  </Folder>\n</kml>\n""")
    end

  end
end