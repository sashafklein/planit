require 'spec_helper'

module Scrapers

  describe Email do

    include ScraperHelper

    # describe "mauricio" do

    #   before do 
    #     @base_name = 'mauricio'
    #     @url = ''
    #     @base_domain = 'email'
    #   end

    #   it "parses the email correctly" do
    #     expect_email_equal(data, expectations)
    #   end

    # end

    # PRIVATE FUNCTIONS

    # INTUIT LOCALE? via
    # => SUBJECT LINE
    # => IN_LOCALE
    # => "GOING TO" / "THINKING ABOUT" / "PLANNING" / "TIPS FOR" / "RECOS FOR" ETC
    # => FREQUENCY
    # BREAK OUT PLACE-NAMES BY LENGTH
    # => SORT BY LENGTH
    # => POP BEFORE/PLACE/AFTER
    # CHUNKING
    # => PARSE INTO PLACE + TEXT + PLACE + TEXT ETC
    # => TURN INTO PARAGRAPHS
    # => TURN INTO SENTENCES
    # => ASSOCIATE WORDS W/ DISTANCES (SPACES -> SENTENCES -> BREAKLINES)
    # => BE WARY OF NEGATION "...N'T" OR "NOT"
    # => 
    # HIGHLIGHT W/ GREEN / YELLOW / RED?
    # STORE IN "TIP BANK"

  end
end 