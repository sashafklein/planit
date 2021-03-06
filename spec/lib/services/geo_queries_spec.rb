require 'rails_helper'

module Services

  describe GeoQueries do
    
    before do 
      class GeoQueryClass
        include GeoQueries
      end
      @instance = GeoQueryClass.new
    end 

    describe "nearby trimmers" do
      # it "gets nearby hashes from full addresses" do
      #   puts "\nALL NEARBY HASHES\n"
      #   full_addresses.each do |full_address| 
      #     nearby_hash = @instance.nearby_hash( full_address )
      #     puts "L: #{nearby_hash[:locality] || "***"} "
      #     puts "R: #{nearby_hash[:region] || "***"} "
      #     puts "C: #{nearby_hash[:country] || "***"} "
      #     puts "   => via => #{full_address}\n"
      #   end
      # end
      # it "gets nearby hashes from full addresses" do
      #   puts "\nNEARBY HASHES MISSING LOCALITY\n"
      #   full_addresses.each do |full_address| 
      #     nearby_hash = @instance.nearby_hash( full_address )
      #     if !nearby_hash[:locality]
      #       puts "L: #{nearby_hash[:locality] || "***"} "
      #       puts "R: #{nearby_hash[:region] || "***"} "
      #       puts "C: #{nearby_hash[:country] || "***"} "
      #       puts "   => via => #{full_address}\n"
      #     end
      #   end
      # end
      # it "gets countries from full addresses" do
      #   puts "\nNO COUNTRY DETECTED FOR\n"
      #   puts full_addresses.select{ |full_address| !@instance.nearby_hash( full_address ) }.join("\n")
      # end
      # it "gets countries from full addresses" do
      #   puts "\nNO REGION DETECTED FOR\n"
      #   puts full_addresses.select{ |full_address| !@instance.find_region( full_address, @instance.find_country( full_address ) ) }.join("\n")
      # end
      # it "gets localities from full addresses" do
      #   puts "\nNO LOCALITY DETECTED FOR\n"
      #   puts full_addresses.select{ |full_address| !@instance.find_locality( full_address ) }.join("\n")
      # end
    end

    private

    def full_addresses
      ["Via Sansone, 9, 16128 Genova, Italy",
      "Platia Agion Asomaton 9, Athina 105 55, Greece",
      "11-17 Exchequer Street, Dublin 2, Ireland",
      "1-25 Ekimotomachi, Kita-ku, Okayama-shi, Okayama-ken 700-0024, Japan",
      "Carrer de la Diputació, 269, 08007 Barcelona, Barcelona, Spain",
      "Calle 11 # 4-1 a 4-99, Bogotá, Cundinamarca, Colombia",
      "5 Carrefour de l'Odéon, 75006 Paris, France",
      "University of California, Berkeley, 2601-2637 Bancroft Way, Berkeley, CA 94704, USA",
      "2130 Center Street, Berkeley, CA 94704, USA",
      "2016 Shattuck Avenue, Berkeley, CA 94704, USA",
      "1504 Shattuck Avenue, Berkeley, CA 94709, USA",
      "1 Centennial Drive, Berkeley, CA 94720, USA",
      "2055 Center Street, Berkeley, CA 94704, USA",
      "2025 Addison Street, Berkeley, CA 94704, USA",
      "2020 Addison Street, Berkeley, CA 94704, USA",
      "1517 Shattuck Avenue, Berkeley, CA 94709, USA",
      "2654 Russell Street, Berkeley, CA 94705, USA",
      "3140 Martin Luther King Junior Way, Berkeley, CA 94703, USA",
      "Rua Augusta 236, 1100-571 Lisboa, Portugal",
      "2086 Allston Way, Berkeley, CA 94704, USA",
      "41 Tunnel Road, Berkeley, CA 94705, USA",
      "2904 College Avenue, Berkeley, CA 94705, USA",
      "Tayrona National Park, Santa Marta, Santa Marta (Distrito Turístico Cultural E Histórico), Magdalena, Colombia",
      "330 East Main Street, Aspen, CO 81611, USA",
      "Avenida Galeana 320, Aviación, 22840 Ensenada, BC, Mexico",
      "Rua Tito Mufato, 1 - Jardim Itamaraty, Região Central, Foz do Iguaçu - PR, Brazil",
      "Alfonso Flores Bello 71, Zona Centro, 91000 Xalapa Enríquez, Vereda, Mexico",
      "17 Rue de la Loge, 13002 Marseille, France",
      "Rosarito 3, Baja California, La Mesa, 22127 Tijuana, BC, Mexico",
      "Grote Marktstraat 24, 2511 BJ Den Haag, Netherlands",
      "Dolores del Río 3112, Anexalos Laureles, Delegacion Playas De Tijuana, Tijuana, BC, Mexico",
      "Nieuwezijds Voorburgwal 359, 1012 RM Amsterdam, Netherlands",
      "243 South Wabash Avenue, Chicago, IL 60604, USA",
      "Necochea 204-276, Valparaíso, Valparaíso, Chile",
      "181-199 East McDowell Road, Phoenix, AZ 85004, USA",
      "Merced 713-797, Santiago, Región Metropolitana, Chile",
      "58 Naruteo-ro, Seocho-gu, Seoul, South Korea",
      "410 Spring Street, Seattle, WA 98104, USA",
      "1611 La Branch Street, Houston, TX 77002, USA",
      "501 Congress Avenue, Austin, TX 78701, USA",
      "Corte Canal, 654-659, 30135 Venezia, Italy",
      "Jalan Melasti No.116, Kuta, Kabupaten Badung, Bali 80361, Indonesia",
      "10-30 Rue de la Gauchetière Ouest, Montréal, QC H2Z 1B9, Canada",
      "150 London Wall, London EC2Y 5HN, UK",
      "721 Jackson Street, Los Angeles, CA 90012, USA",
      "Duque de Mandas, 42-46, 20012 Donostia, Gipuzkoa, Spain",
      "1-29 Ottawa Avenue Northwest, Grand Rapids, MI 49503, USA",
      "Astarloa Kalea, 7, 48008 Bilbao, Bizkaia, Spain",
      "Plaza Santa Ana, 7-13, 28012 Madrid, Madrid, Spain",
      "Via delle Sette Sale, 17, 00184 Roma, Italy",
      "1744-1780 Convention Center Drive, Miami Beach, FL 33139, USA",
      "945 Broadway, San Diego, CA 92101, USA",
      "Piazza del Duomo, 23, 20121 Milano, Italy",
      "77 Nak Niwat, Khwaeng Lat Phrao, Khet Lat Phrao, Krung Thep Maha Nakhon 10230, Thailand",
      "No. 1, Changde Street, Zhongzheng District, Taipei City, Taiwan 100",
      "Juderia, 3, 41004 Sevilla, Sevilla, Spain",
      "1009 Honoapiilani Highway, Lahaina, HI 96761, USA",
      "Avenida General Las Heras 2102-2200, Buenos Aires, Ciudad Autónoma de Buenos Aires, Argentina",
      "5 Rue Auguste Comte, 69002 Lyon, France",
      "Jasomirgottstraße 1, 1010 Wien, Austria",
      "129 Fu Zhou Lu, Huangpu Qu, Shanghai Shi, China, 200085",
      "Rua Washignton Luís, 106 - Centro, Rio de Janeiro - RJ, Brazil",
      "29 Lương Văn Can, Hàng Đào, Hoàn Kiếm, Hà Nội, Vietnam",
      "948 Trường Chinh, 15, Tân Bình, Hồ Chí Minh, Vietnam",
      "280 Washington Street, Boston, MA 02108, USA",
      "83 Albertina Sisulu Road, Johannesburg, 2000, South Africa",
      "1000-1098 Southwest 6th Avenue, Portland, OR 97204, USA",
      "2601-2699 5th Street, Detroit, MI 48201, USA",
      "Budapest, Petőfi tér 3, 1052 Hungary",
      "Ayacucho 502-600, Mendoza, Mendoza, Argentina",
      "Žitná 2055/32, 120 00 Praha-Praha 2, Czech Republic",
      "25 Townsend Street, Dublin, Ireland",
      "70 Opalipali Place, Kula, HI 96790, USA",
      "9 Avenue Victoria, 75004 Paris, France",
      "416 South Ventura Street, Ojai, CA 93023, USA",
      "Jalan Raya Ubud No.23, Ubud, Kabupaten Gianyar, Bali 80571, Indonesia",
      "Plaza de la Constitución GDF, Centro, Cuauhtémoc, 06000 Ciudad de México, D.F., Mexico",
      "30 Grove Street, San Francisco, CA 94102, USA",
      "Piazza Re Enzo, 2, 40124 Bologna, Italy",
      "Am Kupfergraben 10, 10117 Berlin, Germany",
      "John O Connor 402-500, San Carlos de Bariloche, Río Negro, Argentina",
      "Viale Lavagnini Spartaco, 35, 50129 Firenze, Italy",
      "Villa la Angostura 3015-3099, Neuquén, Neuquén, Argentina",
      "Capitán Drury 602-700, San Martín de Los Andes, Neuquén, Argentina",
      "1 Rue Tonduti de l'Escarène, 06000 Nice, France",
      "12 Jetty Street, Cape Town City Centre, Cape Town, 8000, South Africa",
      "Avenida del Monasterio de Nuestra Señora de Prado, 5, 47014 Valladolid, Valladolid, Spain",
      "2 Chome-7-3 Dōgenzaka, Shibuya-ku, Tōkyō-to 150-0043, Japan",
      "2 Chome-14-7 Yoyogi, Shibuya-ku, Tōkyō-to 151-0053, Japan",
      "Calle 16 # 5-1 a 5-99, Bogotá, Cundinamarca, Colombia",
      "Circunvalar # 2 a 100, Bogotá, Cundinamarca, Colombia",
      "Calle 10 # 7-1 a 7-99, Bogotá, Cundinamarca, Colombia",
      "Zipaquira Cundinamarca, Colombia",
      "10 Wexford Street, Dublin 2, Ireland",
      "33 Exchequer Street, Dublin 2, Ireland",
      "8-9 Sussex Terrace, Dublin 4, Ireland",
      "7-8 Leeson Street Lower, Dublin, Ireland",
      "153 Capel Street, Dublin 1, Ireland",
      "28 Jones' Road, Dublin, Ireland",
      "1-31 O'Connell Bridge, Dublin, Ireland",
      "6 Merrion Row, Dublin, Ireland",
      "Carrera 2 # 39-36, Cartagena, Bolívar, Colombia",
      "Calle Vargas Ponce, 6, 30310 Cartagena, Murcia, Spain",
      "Hotel Boutique Casa Quero, Cartagena De Indias (Distrito Turístico Y Cultural), Bolívar, Colombia",
      "Calle 31 # 84-38, Cartagena De Indias (Distrito Turístico Y Cultural), Bolívar, Colombia",
      "Carrera 5 # 62-28, Bogotá, Cundinamarca, Colombia",
      "Carrera 5 # 62-18, Bogotá, Cundinamarca, Colombia",
      "Carrera 5 # 62-6, Bogotá, Cundinamarca, Colombia",
      "Calle 95 # 14-17, Bogotá, Cundinamarca, Colombia",
      "Calle 27 # 19-73, Bogotá, Cundinamarca, Colombia",
      "Calle 11 # 66B-21, Bogotá, Cundinamarca, Colombia",
      "Calle 11 # 68C-14, Bogotá, Cundinamarca, Colombia",
      "Calle 16 # 80C-41, Bogotá, Cundinamarca, Colombia",
      "Calle 29 # 32A-84, Bogotá, Cundinamarca, Colombia",
      "Calle 82 # 104-10, Bogotá, Cundinamarca, Colombia",
      "Calle 82 # 104-78, Bogotá, Cundinamarca, Colombia",
      "Carrera 3 # 138S-72, Bogotá, Cundinamarca, Colombia",
      "Calle 94 # 67-12, Bogotá, Cundinamarca, Colombia",
      "Calle 10 # 72A-72, Bogotá, Cundinamarca, Colombia",
      "Carrera 5 # 62-46, Bogotá, Cundinamarca, Colombia",
      "7500 1st Coast Highway, Fernandina Beach, FL 32034, USA",
      "1408 Lewis Street, Fernandina Beach, FL 32034, USA",
      "2601 Atlantic Avenue, Fernandina Beach, FL 32034, USA",
      "1 South Front Street, Fernandina Beach, FL 32034, USA",
      "801 Beech Street, Fernandina Beach, FL 32034, USA",
      "22 South 3rd Street, Fernandina Beach, FL 32034, USA",
      "6800 1st Coast Highway, Fernandina Beach, FL 32034, USA",
      "4750 Amelia Island Parkway, Fernandina Beach, FL 32034, USA",
      "227 South 7th Street, Fernandina Beach, FL 32034, USA",
      "3 Chome-7-1 Nishishinjuku, Shinjuku-ku, Tōkyō-to 160-0023, Japan",
      "133 Furugome, Narita-shi, Chiba-ken 286-0104, Japan",
      "6 Chome-6-2 Nishishinjuku, Shinjuku-ku, Tōkyō-to 160-0023, Japan",
      "1 Chome-8-10 Hase, Kamakura-shi, Kanagawa-ken 248-0016, Japan",
      "5 Chome-13-21 Zaimokuza, Kamakura-shi, Kanagawa-ken 248-0013, Japan",
      "3 Chome-11-2 Hase, Kamakura-shi, Kanagawa-ken 248-0016, Japan",
      "2 Chome-7-4 Jōmyōji, Kamakura-shi, Kanagawa-ken 248-0003, Japan",
      "4 Chome-2-28 Hase, Kamakura-shi, Kanagawa-ken 248-0016, Japan",
      "279 Toyokawachō, Ise-shi, Mie-ken 516-0042, Japan",
      "104 Yamanouchi, Kamakura-shi, Kanagawa-ken 247-0062, Japan",
      "139 Motohakone, Hakone-machi, Ashigarashimo-gun, Kanagawa-ken 250-0522, Japan",
      "71 Tōnosawa, Hakone-machi, Ashigarashimo-gun, Kanagawa-ken 250-0315, Japan",
      "1 Chome-3-1 Asakusa, Taitō-ku, Tōkyō-to 111-0032, Japan",
      "2 Chome-3-61 Asakusa, Taitō-ku, Tōkyō-to 111-0032, Japan",
      "4 Chome-15-4 Jingūmae, Shibuya-ku, Tōkyō-to 150-0001, Japan",
      "2 Chome-10-5 Nagatachō, Chiyoda-ku, Tōkyō-to 100-0014, Japan",
      "1 Chome-20-28 Shibuya, Shibuya-ku, Tōkyō-to 150-0002, Japan",
      "1 Chome-4-1 Yokoami, Sumida-ku, Tōkyō-to 130-0015, Japan",
      "1 Chome-3-28 Yokoami, Sumida-ku, Tōkyō-to 130-0015, Japan",
      "5 Chome-3-4 Roppongi, Minato-ku, Tōkyō-to 106-0032, Japan",
      "5-20 Uenokōen, Taitō-ku, Tōkyō-to 110-0007, Japan",
      "3-1 Kitanomarukōen, Chiyoda-ku, Tōkyō-to 102-0091, Japan",
      "6 Chome-18-2 Ginza, Chūō-ku, Tōkyō-to 104-0061, Japan",
      "6 Chome-12-2 Roppongi, Minato-ku, Tōkyō-to 106-0032, Japan",
      "4-1 Marunouchi, Matsumoto-shi, Nagano-ken 390-0873, Japan",
      "8967 Iriyamabe, Matsumoto-shi, Nagano-ken 390-0222, Japan",
      "1682 Ichinomiyamachi, Takayama-shi, Gifu-ken 509-3505, Japan",
      "1 Shiroyama, Takayama-shi, Gifu-ken 506-0822, Japan",
      "106 Ogimachi, Shirakawa-mura, Ōno-gun, Gifu-ken 501-5627, Japan",
      "1-22 Kenrokumachi, Kanazawa-shi, Ishikawa-ken 920-0936, Japan",
      "625 Gionmachi Kitagawa, Higashiyama-ku, Kyōto-shi, Kyōto-fu 605-0073, Japan",
      "511 Washiochō, Higashiyama-ku, Kyōto-shi, Kyōto-fu 605-0072, Japan",
      "3 Kyōtogyoen, Kamigyō-ku, Kyōto-shi, Kyōto-fu 602-0881, Japan",
      "566-25 Komatsuchō, Higashiyama-ku, Kyōto-shi, Kyōto-fu 605-0811, Japan",
      "30 Shūgakuin Hayashinowaki, Sakyō-ku, Kyōto-shi, Kyōto-fu 606-8057, Japan",
      "32-3 Jōdoji Ishibashichō, Sakyō-ku, Kyōto-shi, Kyōto-fu 606-8406, Japan",
      "13-1 Ryōanji Goryōnoshitachō, Ukyō-ku, Kyōto-shi, Kyōto-fu 616-8001, Japan",
      "1 Kinkakujichō, Kita-ku, Kyōto-shi, Kyōto-fu 603-8361, Japan",
      "25 Murasakino Shimomonzenchō, Kita-ku, Kyōto-shi, Kyōto-fu 603-8215, Japan",
      "28 Nakanochō (Sanjōdōri), Nakagyō-ku, Kyōto-shi, Kyōto-fu 604-8083, Japan",
      "1 Saganonomiyachō, Ukyō-ku, Kyōto-shi, Kyōto-fu 616-8393, Japan",
      "170 Tokiwachō (Yamatoōjidōri), Higashiyama-ku, Kyōto-shi, Kyōto-fu 605-0079, Japan",
      "364A Broadway, Cambridge, MA 02139, USA",
      "526 Shimokawarachō, Higashiyama-ku, Kyōto-shi, Kyōto-fu 605-0825, Japan",
      "1 Kōrakuen, Kita-ku, Okayama-shi, Okayama-ken 703-8257, Japan",
      "2 Chome-3-1 Marunouchi, Kita-ku, Okayama-shi, Okayama-ken 700-0823, Japan",
      "1 Chome-1-15 Chūō, Kurashiki-shi, Okayama-ken 710-0046, Japan",
      "4-1 Honmachi, Kurashiki-shi, Okayama-ken 710-0054, Japan",
      "2 Chome-25-22 Achi, Kurashiki-shi, Okayama-ken 710-0055, Japan",
      "2 Chome-23-10 Achi, Kurashiki-shi, Okayama-ken 710-0055, Japan",
      "2 Chome-23-9 Achi, Kurashiki-shi, Okayama-ken 710-0055, Japan",
      "1-1 Katsuramisono, Nishikyō-ku, Kyōto-shi, Kyōto-fu 615-8014, Japan",
      "570-6 Gionmachi Minamigawa, Higashiyama-ku, Kyōto-shi, Kyōto-fu 605-0074, Japan",
      "901 Higashishiokōji Mukaihatachō, Shimogyō-ku, Kyōto-shi, Kyōto-fu 600-8213, Japan",
      "400 Zōshichō, Nara-shi, Nara-ken 630-8211, Japan",
      "185-6 Higashiuoyachō, Nakagyō-ku, Kyōto-shi, Kyōto-fu 604-8055, Japan",
      "11 Naitōmachi, Shinjuku-ku, Tōkyō-to 160-0014, Japan",
      "2 Chome-6-8 Minamiaoyama, Minato-ku, Tōkyō-to 107-0062, Japan",
      "1-3 Chiyoda, Chiyoda-ku, Tōkyō-to 100-0001, Japan",
      "2 Chome-1-5 Hatagaya, Shibuya-ku, Tōkyō-to 151-0072, Japan",
      "25-10 Udagawachō, Shibuya-ku, Tōkyō-to 150-0042, Japan",
      "2 Chome-3-1 Kyōdō, Setagaya-ku, Tōkyō-to 156-0052, Japan",
      "8 Chome-5-25 Ginza, Chūō-ku, Tōkyō-to 104-0061, Japan",
      "4 Chome-16-10 Tsukiji, Chūō-ku, Tōkyō-to 104-0045, Japan",
      "2 Chome-25-8 Matsugaya, Taitō-ku, Tōkyō-to 111-0036, Japan",
      "1 Chome-11-3 Tōyō, Kōtō-ku, Tōkyō-to 135-0016, Japan",
      "8 Pleasant Street, Kennebunkport, ME 04046, USA",
      "58 Foreside Common Road, Falmouth, ME 04105, USA",
      "90 Congress Street, Portland, ME 04101, USA",
      "3 Canal Plaza, Portland, ME 04101, USA",
      "157-195 Eastern Promenade, Portland, ME 04101, USA",
      "109 Fox Street, Portland, ME 04101, USA",
      "9 Bolton Street, Portland, ME 04102, USA",
      "47 India Street, Portland, ME 04101, USA",
      "7 Custom House Street, Portland, ME 04101, USA",
      "52 Exchange Street, Portland, ME 04101, USA",
      "188A State Street, Portland, ME 04101, USA",
      "43 India Street, Portland, ME 04101, USA",
      "288 Fore Street, Portland, ME 04101, USA",
      "885-887 Maine 100, Portland, ME 04103, USA",
      "45 Middle Street, Portland, ME 04101, USA",
      "82 Middle Street, Portland, ME 04101, USA",
      "16 Chauncey Creek Road, Kittery Point, ME 03905, USA",
      "55 Chestnut Street, Camden, ME 04843, USA",
      "31 Elm Street, Camden, ME 04843, USA",
      "67 Parsons Valley Road, Thorndike, ME 04986, USA",
      "Acadia National Park, 707 Cadillac Summit Road, Bar Harbor, ME 04609, USA",
      "35 West Street, Bar Harbor, ME 04609, USA",
      "Calle Enric Granados, 83, 08008 Barcelona, Barcelona, Spain",
      "Carrer de Provença, 230, 08036 Barcelona, Barcelona, Spain",
      "Carrer de Sardenya, 316, 08013 Barcelona, Barcelona, Spain",
      "Calle Indústria, 79, 08025 Barcelona, Barcelona, Spain",
      "Carrer de Provença, 169, 08026 Barcelona, Barcelona, Spain",
      "Carrer d'Olot, 5, 08024 Barcelona, Barcelona, Spain",
      "Avinguda del Paraŀlel, 164, 08015 Barcelona, Barcelona, Spain",
      "Carrer del Poeta Cabanyes, 20, 08004 Barcelona, Barcelona, Spain",
      "Avinguda Miramar, 2, 08038 Barcelona, Barcelona, Spain",
      "Plaça de Sant Galdric, 96, 08001 Barcelona, Barcelona, Spain",
      "Carrer de la Cirera, 2-4, 08003 Barcelona, Barcelona, Spain",
      "Carrer de la Barra de Ferro, 9, 08003 Barcelona, Barcelona, Spain",
      "Carrera 13 # 49-1 a 49-99, Bogotá, Cundinamarca, Colombia",
      "Carrer de Montcada, 22, 08003 Barcelona, Barcelona, Spain",
      "Carrer de l'Arc de Sant Vicenç, 3, 08003 Barcelona, Barcelona, Spain",
      "Calle Comerç, 29, 08003 Barcelona, Barcelona, Spain",
      "Carrer Caputxes, 5, 08003 Barcelona, Barcelona, Spain",
      "Carrer de Freixures, 14, 08003 Barcelona, Barcelona, Spain",
      "Carrer de l'Institut Escola, 16.I, 08003 Barcelona, Barcelona, Spain",
      "Carrer Xuclà, 5, 08001 Barcelona, Barcelona, Spain",
      "Plaça de les Olles, 8, 08003 Barcelona, Barcelona, Spain",
      "Carrer del Vidre, 1, 08002 Barcelona, Barcelona, Spain",
      "Calle Argenteria, 51, 08003 Barcelona, Barcelona, Spain",
      "Carrer l'Almirall Aixada, 23, 08003 Barcelona, Barcelona, Spain",
      "Carrer de la Reina Cristina, 7, 08003 Barcelona, Barcelona, Spain",
      "Carrer de Mallorca, 238, 08008 Barcelona, Barcelona, Spain",
      "Carrer del Vidre, 2, 08002 Barcelona, Barcelona, Spain",
      "Calle 51 # 9-57 Apt 701, Bogota, Cundinamarca, Colombia",
      "Plaça de Jacint Reventós, 62, 08003 Barcelona, Barcelona, Spain",
      "Calle Muntaner, 171, 08036 Barcelona, Barcelona, Spain",
      "Carrer de l'Argenteria, 37, 08003 Barcelona, Barcelona, Spain",
      "Carrer de València, 167, 08011 Barcelona, Barcelona, Spain",
      "Carrer de Sant Honorat, 10, 08002 Barcelona, Barcelona, Spain",
      "Calle LA Rambla, 115, 08002 Barcelona, Barcelona, Spain",
      "Carrer de la Reina Elionor, 2-4, 08002 Barcelona, Barcelona, Spain",
      "Carrer del Rec, 24, 08003 Barcelona, Barcelona, Spain",
      "Carrer Comercial, 9, 08003 Barcelona, Barcelona, Spain",
      "Calle Major de Sarrià, 49, 08017 Barcelona, Barcelona, Spain",
      "Avinguda dels Montanyans, 41, 08038 Barcelona, Barcelona, Spain",
      "Carrer de la Font del Mont, 1, 08017 Barcelona, Barcelona, Spain",
      "Carrer de Sant Pere Més Alt, 11-13, 08003 Barcelona, Barcelona, Spain",
      "Carrer dels Sombrerers, 2, 08003 Barcelona, Barcelona, Spain",
      "Carrer d'Aribau, 56-58, 08011 Barcelona, Barcelona, Spain",
      "Calle la Rambla, 74, 08002 Barcelona, Barcelona, Spain",
      "Les Rambles, 123, 08002 Barcelona, Barcelona, Spain",
      "Avinguda de la Catedral, 6, 08002 Barcelona, Barcelona, Spain",
      "Rambla de Santa Mònica, 4, 08002 Barcelona, Barcelona, Spain",
      "Carrer de Montjuïc del Bisbe, 3, 08002 Barcelona, Barcelona, Spain",
      "Carrer Avinyó, 9, 08002 Barcelona, Barcelona, Spain",
      "Carrer Germans Desvalls, 51-91, 08035 Barcelona, Barcelona, Spain",
      "Carrer dels Àngels, 5-7, 08001 Barcelona, Barcelona, Spain",
      "Carrer de Santa Maria, 18, 08003 Barcelona, Barcelona, Spain",
      "Plaça de Vicenç Martorell, 4, 08001 Barcelona, Barcelona, Spain",
      "Rambla dels Caputxins, 76, 08002 Barcelona, Barcelona, Spain",
      "Calle Stuart No 7-14, Cartagena, Colombia",
      "58 rue Saint-Dominique,  Paris, 75007, France",
      "4741 SE Hawthorne Blvd,  Portland, OR 97215",
      "125 West 55th St (btwn 6th and 7th Avenue), New York, NY 10019",
      "3228 Sacramento Street San Francisco, CA",
      "740 Valencia St (btwn 18th & 19th St), San Francisco, CA 94110",
      "1 Telegraph Hill Blvd (btwn Lombard St & Union St), San Francisco, CA 94133, United States",
      "12593 Donner Pass Road, Truckee, CA, United States",
      "222 Mason Street, San Francisco, California 94102",
      "1525 Fillmore Street, San Francisco, CA 94115, United States",
      "1028 Market Street, San Francisco, CA 94102, United States",
      "3570 South Las Vegas Boulevard, Las Vegas, Nevada 89109",
      "135 West 56th Street, New York, NY 10019, United States",
      "Carretrera federal a cuernavaca, san pedro martir, México D.F., Mexico",
      "3359 Cesar Chavez (at Mission St), San Francisco, CA 94110, United States",
      "19659 Boreal Ridge Road, Truckee, CA 96161, United States",
      "10046 Donner Pass Road, Truckee, California 96161",
      "10142 Rue Hilltop (at Brockway Road), Truckee, CA 96161, United States",
      "5001 Northstar Drive, Truckee, California 96161",
      "Hwy 89 (Emerald Bay Road), Lake Tahoe, CA 96150, United States",
      "1169 Ski Run Blvd #5, South Lake Tahoe, CA 96151, United States",
      "18 Highway 50 (at Stateline Ave), Lake Tahoe, NV 89449, United States",
      "3100 Harrison, South Lake Tahoe, CA 96150, United States",
      "4080 Lake Tahoe Boulevard, South Lake Tahoe, CA 96150, United States",
      "3819 Saddle Road, South Lake Tahoe, CA 96150, United States",
      "10007 Bridge St (Donner Pass Road), Truckee, CA 96161, United States",
      "1960 Squaw Valley Road (Route 89), Olympic Valley, CA 96146, United States",
      "55 US 50 (at Lake Pkwy), Stateline, NV 89449, United States",
      "4104 Lakeshore Boulevard, South Lake Tahoe, CA 96150, United States",
      "Calle 28 # 6-2 a 6-100, Bogotá, Cundinamarca, Colombia",
      "Cra 7 10 - 80, Bogotá, Bogotá D.C., Colombia",
      "Calle 68 # 95-2 a 95-100, Bogotá, Cundinamarca, Colombia",
      "Avenida Carrera 7, Bogotá, Colombia",
      "Cabo Pacifica S/N, Mexico Cabo San Lucas, Baja, México",
      "Las Animas Bajas, 23407 San José del Cabo, Baja California Sur, México",
      "Blvd. Antonio Mijares 4, 23400 San José del Cabo, Baja California Sur, México",
      "Plaza Mijares (Miguel Hidalgo e/ M. Doblado y Álvaro Obregón), 23400 San José del Cabo, Baja California Sur, México",
      "Cabo San Lucas, Baja California Sur, México",
      "Andador Casa Dorada. Avenue del Pescador local 6 Medano Beach, 23450 Cabo San Lucas, Baja California Sur, Mexico",
      "Palmilla, Cabo San Lucas, México",
      "Av. del Pescador, Baja California Sur, México",
      "Carr. Transpeninsular Km. 28.5, 23400 San José del Cabo, Baja California Sur, México",
      "1137 Calle Comonfort, 23400 San José del Cabo, Baja California Sur, Mexico",
      "Alvaro Obregon, Centro, 23400 San José del Cabo, Baja California Sur, Mexico",
      "1 Camino del Mar (Capella Pedregal), Cabo San Lucas, Baja California Sur, México",
      "México",
      "calle 70a 9-95 esquina, Bogotá, Bogotá D.C., Colombia",
      "3 carrefour de l'Odéon, 75006 Paris, France",
      "2 East 61st St (at 5th Ave), New York, NY 10065, United States",
      "700 5th Ave (at East 55th Street), New York, NY 10019, United States",
      "17 Barrow St (btwn West 4th St & 7th Avenue S), New York, NY 10014, United States",
      "11 Madison Ave (at East 24th St), New York, NY 10010, United States",
      "85 10th Ave (btwn 15th & 16th St), New York, NY 10011, United States",
      "768 5th Ave (at Central Park S), New York, NY 10019, United States",
      "155 West 51st St (btwn 6th & 7th Ave), New York, NY 10019, United States",
      "80 Spring St (at Crosby St), New York, NY 10012, United States",
      "99 Prince St (at Mercer Street), New York, NY 10012, United States",
      "40 West 57th St (btwn 5th & 6th Ave), New York, NY 10019, United States",
      "42 East 58th St (btwn Madison & Park Ave), New York, NY 10022, United States",
      "311 West 43rd St (at 8th Avenue), New York, NY 10036, United States",
      "42 East 20th St (btwn Broadway & Park Avenue), New York, NY 10003, United States",
      "10 Columbus Circle Ste 4 (at West 60th St), New York, NY 10023, United States",
      "376 W Broadway (btwn Spring & Broome), New York, NY 10012, United States",
      "18 9th Ave (btwn Gansevoort & West 13th St), New York, NY 10014, United States",
      "11 West 53rd St (btwn 5th & 6th Ave), New York, NY 10019, United States",
      "1000 5th Ave (btwn East 80th & East 84th St), New York, NY 10028, United States",
      "1320 Castro Street, San Francisco, CA 94114, USA",
      "Calle 69 n 11-58, Bogotá, Bogotá D.C., Colombia",
      "1531 Melrose Avenue Seattle, WA, 98122"]
    end
  end

end