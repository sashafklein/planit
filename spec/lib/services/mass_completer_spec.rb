require 'spec_helper'

module Services
  describe MassCompleter do

    include ScraperHelper

    before do 
      @base_name = 'cartagena'
      @base_domain = 'nytimes'
      @expectations = expectations
    end

    describe "complete!" do
      it 'delegates to an individual completer for each item' do
        allow(Completer).to receive(:new) { double(complete!: 'completed!') }
        @mass_completer = MassCompleter.new(@expectations, 'user')
        completions = @mass_completer.complete!
        
        expect(completions.all? { |c| c == 'completed!' } ).to eq true
        expect(completions.length).to eq(@expectations.length)
      end
    end
  end
end