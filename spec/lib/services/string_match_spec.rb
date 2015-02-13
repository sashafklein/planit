require 'spec_helper'

module Services
  describe StringMatch do
    describe "internals" do
      before do 
        @matcher = StringMatch.new "The Hilton Tokyo", "Executive Lounge - Hilton Tokyo (ヒルトン東京 エグゼクティブラウンジ)"
      end

      it "initialization removes all foreign chars, symbols, articles" do
        expect( @matcher.main ).to eq "hilton tokyo"
        expect( @matcher.target ).to eq "executive lounge hilton tokyo"
      end

      it "matched_words" do
        expect( @matcher.send(:matched_words) ).to eq %w( hilton tokyo )
      end
    end

    describe "value" do
      it "Fuunji" do
        matcher = StringMatch.new("Fuunji", "Fu-Unji")
        expect( matcher.value ).to be > 0.9
        matcher2 = StringMatch.new("Fuunji", "Fu-Unji 風雲児")
        expect( matcher.value ).to be > 0.9
      end

      it "Hard Rock Cafe v Heard Rock Restaurant" do
        matcher = StringMatch.new("Hard Rock Cafe", "Heard Rock Restaurant")
        expect( matcher.value ).to be_within(0.07).of 0.6

        matcher2 = StringMatch.new("Hard Rock Cafe", "Hard Rock Restaurant")
        expect( matcher2.value ).to be_within(0.07).of 0.75

        matcher3 = StringMatch.new("Hard Rock Cafe", "Heard Rock Cafe")
        expect( matcher3.value ).to be_within(0.07).of 0.85
      end

      it "Penthouse room with a view (Airbnb) v A Seis Manos" do
        matcher = StringMatch.new("Penthouse room with a view (Airbnb)", "A Seis Manos")
        expect( matcher.value ).to be < 0.3
        matcher2 = StringMatch.new("Penthouse room with a view (Airbnb)", "A Seis Manos", parentheses: true)
        
        # Can specify to keep parentheticals
        expect( matcher.main ).to eq "penthouse room with view"
        expect( matcher2.main ).to eq "penthouse room with view airbnb"
        expect( matcher.value ).not_to eq matcher2.value
      end

      it "Penthouse room with a view (Airbnb) v CUN Sede A (Administrativa)" do
        matcher = StringMatch.new("Penthouse room with a view (Airbnb)", "CUN Sede A (Administrativa)")
        expect( matcher.value ).to be_within(0.07).of 0.3
      end

      it "Penthouse room with a view (Airbnb) v Instituto del Corazon de Bucaramanga S.A." do
        matcher = StringMatch.new("Penthouse room with a view (Airbnb)", "Instituto del Corazon de Bucaramanga S.A")
        expect( matcher.value ).to be_within(0.07).of 0.2
      end

      it "The rain in Spain v The rain in Spain falls mainly" do
        matcher = StringMatch.new("The rain in Spain", "The rain in Spain falls mainly")
        expect( matcher.value ).to be_within(0.07).of 0.75
      end

      it "There once was a man in peru, There once was a woman in peru" do
        matcher = StringMatch.new("There once was a man in peru", "There once was a woman in peru")
        expect( matcher.value ).to be_within(0.07).of 0.95
      end

      it "The sentence has a lot of articles, sentence has lot articles" do
        matcher = StringMatch.new("The sentence has a lot of articles", "sentence has lot articles")
        expect( matcher.value ).to be_within(0.07).of 1
      end

      it "Contigo" do
        matcher = StringMatch.new("Contigo", "Contigo Restaurant")
        expect( matcher.value ).to be_within(0.07).of 0.75
      end

      it "Park Hyatt v Park Hyatt Hotel" do
        matcher = StringMatch.new("Park Hyatt", "Park Hyatt Hotel")
        expect( matcher.value ).to be_within(0.07).of 0.85
      end

      it "handles characters like a champ!" do
        matcher = StringMatch.new("Wagas | 沃歌斯", "沃歌斯 - Wagas")
        expect( matcher.value ).to be_within(0.07).of 0.95

        matcher2 = StringMatch.new("Wagas", "Wagas | 沃歌斯")
        expect( matcher2.value ).to eq matcher.value

        matcher3 = StringMatch.new("沃歌斯", "沃歌斯")
        expect( matcher3.value ).to eq 1.0

        matcher4 = StringMatch.new("沃歌斯", "エグゼ")
        expect( matcher4.value ).to eq 0

        matcher5 = StringMatch.new("沃歌斯", "沃歌斯エグゼ")
        expect( matcher5.value ).to be_within(0.07).of 0.5

        matcher6 = StringMatch.new("沃歌斯", "&#27779;&#27468;&#26031;") # Decimal-encoded equivalent
        expect( matcher6.value ).to eq 1
      end

      it "takes the main string composition into account when comparing" do
        matcher = StringMatch.new("Wagas", "Wagas | 沃歌斯")
        expect( matcher.value ).to eq 1

        matcher2 = StringMatch.new("Wagas | 沃歌斯", "Wagas | 沃歌斯")
        expect( matcher2.value ).to eq 1

        matcher3 = StringMatch.new("Wagas | エグゼ", "Wagas | 沃歌斯")
        expect( matcher3.value ).to be_within(0.07).of 0.65

        matcher4 = StringMatch.new("沃歌斯", "Wagas | 沃歌斯")
        expect( matcher4.value ).to eq 1.0
      end
    end
  end
end