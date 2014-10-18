describe Clusterer do
  describe "clusters" do
    describe "with one clear cluster" do
      
      before { @clusterer = cluster_from_names [] }

      it "groups appropriately" do
        expect(@clusterer.to_json).to eq([
          [{
             location_name: [lat, lon],
             location_name: [lat, lon]
          }],
        ])
      end
    end

    describe "with two clear clusters" do
      
      before { @clusterer = cluster_from_names [] }

      it "groups appropriately" do
      end
    end

    describe "with three clear clusters" do
      
      before { @clusterer = cluster_from_names [] }

      it "groups appropriately" do
      end
    end

    describe "with 10 clear clusters" do
      
      before { @clusterer = cluster_from_names [] }

      it "groups appropriately" do
      end
    end

    describe "with borderline 1-2 clusters" do
      
      before { @clusterer = cluster_from_names [] }

      it "groups appropriately" do
      end
    end
  end
end

def clusterer_from_names(location_names)
  locations = location_names.map{ |n| create("#{n}_location") }
end