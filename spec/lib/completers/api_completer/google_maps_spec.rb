require 'rails_helper'

module Completers
  describe ApiCompleter::GoogleMaps, :vcr do

    describe "searching for data" do
      it "finds Wagas with basic location info" do
        v = completer('Wagas', { locality: 'Shanghai', country: 'China'})
        expect( v.website ).to eq "http://www.wagas.com.cn/"
        expect( v.names ).to eq ["Wagas"]
        expect( v.street_addresses ).to eq ["1168 Nanjing West Road"]
        expect( v.full_address ).to eq "1168 Nanjing West Road, Jing'an, Shanghai, China"
      end

      it "finds Wagas with LatLon" do
        v = completer('Wagas', { lat: 31.237360, lon: 121.484825 })
        expect( v.website ).to eq "http://www.wagas.com.cn/"
        expect( v.names ).to eq ["Wagas"]
        expect( v.street_addresses ).to eq ["288 Jiujiang Road"]
        expect( v.full_address ).to eq "288 Jiujiang Road, Huangpu, Shanghai, China"
        expect( v.phones ).to eq ["+86 21 3366 5026"]
      end

      it "finds Wagas with nearby" do
        v = completer('Wagas', { nearby: 'Jing An, Shanghai, China'})
        expect( v.website ).to eq "http://www.wagas.com.cn/"
        expect( v.names ).to eq ["Wagas"]
        expect( v.street_addresses ).to eq ["1168 Nanjing West Road"]
        expect( v.full_address ).to eq "1168 Nanjing West Road, Jing'an, Shanghai, China"
        expect( v.phones ).to eq ["+86 21 5292 5228"]
      end

      it "finds Wagas with a full address" do
        v = completer("Wagas", { full_address: "796 Dongfang Rd, Shanghai, China"})
        expect( v.website ).to eq "http://www.wagas.com.cn/"
        expect( v.names ).to eq ["Wagas"]
        expect( v.street_addresses ).to eq ["796 Dongfang Road"]
        expect( v.full_address ).to eq "796 Dongfang Road, Pudong, Shanghai, China"
        expect( v.phones ).to eq ["+86 21 6194 0298"]
      end

      it "finds Wagas with a foreign full address" do
        v = completer("Wagas", { full_address: "Dongfang Rd, 796号 96广场, Shanghai, China"})
        expect( v.name ).to eq "Wagas"
        expect( v.website ).to eq "http://www.wagas.com.cn/"
        expect( v.street_address ).to eq "796 Dongfang Road"
        expect( v.full_address ).to eq "796 Dongfang Road, Pudong, Shanghai, China"
        expect( v.phones ).to eq ["+86 21 6194 0298"]
      end

      it "finds Tayrona Tented Lodge" do
        v = completer("Tayrona Tented Lodge", { lat: 11.27099347, lon: -73.84327023999998 })
        expect( v.lat ).to float_eq 11.270994
        expect( v.lon ).to float_eq -73.84327
        expect( v.names ).to eq ["Tayrona Tented Lodge"]
        expect( v.street_addresses ).to eq ["Km 38 +300 mts, vía Santa Marta- Rioacha"]
        expect( v.full_address ).to eq "Km 38 +300 mts, vía Santa Marta- Rioacha, Santa Marta, 575000, Colombia"
        expect( v.phones ).to eq ["+57 317 3386747"]
      end

      it "finds Fuunji with basic nearby" do
        v = completer("Fuunji", { nearby: "Shibuya, Tokyo"} )
        expect( v.country ).to eq "Japan"
        expect( v.region ).to eq "Tokyo"
        expect( v.locality ).to eq "Shibuya"
        expect( v.lat ).to float_eq 35.693757
        expect( v.lon ).to float_eq 139.702594
        expect( v.website ).to eq "http://www.fu-unji.com/"
        expect( v.names ).to eq ["風雲児"]
        expect( v.street_addresses ).to eq ["2 Chome-１４−3 Yoyogi"]
        expect( v.full_address ).to eq "2 Chome-１４−3 Yoyogi, Shibuya, Tokyo 151-0053, Japan"
        expect( v.phones ).to eq ["+81 3-6413-8480"]
      end

      it "takes problematic terms out of nearby before searching" do
        v = completer("Fuunji", {nearby: 'Shibuya, Tokyo Prefecture, Japan'})
        expect( v.country ).to eq "Japan"
        expect( v.region ).to eq "Tokyo"
        expect( v.locality ).to eq "Shibuya"
        expect( v.lat ).to float_eq 35.693757
        expect( v.lon ).to float_eq 139.702594
        expect( v.website ).to eq "http://www.fu-unji.com/"
        expect( v.names ).to eq ["風雲児"]
        expect( v.street_addresses ).to eq ["2 Chome-１４−3 Yoyogi"]
        expect( v.full_address ).to eq "2 Chome-１４−3 Yoyogi, Shibuya, Tokyo 151-0053, Japan"
        expect( v.phones ).to eq ["+81 3-6413-8480"]

        expect( @c.last_url ).to include("Tokyo,%20Japan") # cuts out Prefecture
      end

      it "takes problematic terms out of location vals before searching" do
        v = completer("Fuunji", {sublocality: 'Shibuya', locality: 'Tokyo Prefecture', country: 'Japan'})
        expect( v.country ).to eq "Japan"
        expect( v.region ).to eq "Tokyo"
        expect( v.locality ).to eq "Shibuya"
        expect( v.lat ).to float_eq 35.693757
        expect( v.lon ).to float_eq 139.702594
        expect( v.website ).to eq "http://www.fu-unji.com/"
        expect( v.names ).to eq ["風雲児"]
        expect( v.street_addresses ).to eq ["2 Chome-１４−3 Yoyogi"]
        expect( v.full_address ).to eq "2 Chome-１４−3 Yoyogi, Shibuya, Tokyo 151-0053, Japan"
        expect( v.phones ).to eq ["+81 3-6413-8480"]

        expect( @c.last_url ).to include("Tokyo,%20Japan") # cuts out Prefecture
      end
    end

    def completer(name, attrs)
      attrs = attrs.merge( {names: [name]} ).to_sh
      pip = PlaceInProgress.new(attrs.except(:nearby))
      @c = ApiCompleter::GoogleMaps.new(pip, attrs)
      @c.find; @c.venues.first
    end
  end
end