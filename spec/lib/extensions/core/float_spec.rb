require 'spec_helper'

describe Float do
  describe "decimals" do
    it "computes the number of decimals" do
      expect( 3.1.decimals ).to eq 1
      expect( 3.14.decimals ).to eq 2
      expect( 3.141.decimals ).to eq 3
      expect( 3.14159.decimals ).to eq 5
    end
  end

  describe "points of similarity" do
    it "compares how many decimals of similarity two floats have" do
      expect( 3.14159.points_of_similarity(3.1) ).to eq 1
      expect( 3.14159.points_of_similarity(3.14) ).to eq 2
      expect( 3.14159.points_of_similarity(3.139) ).to eq 2
      expect( 3.14159.points_of_similarity(3.131) ).to eq 1
      expect( 3.14159.points_of_similarity(33.1) ).to eq 0
      expect( 3.14159.points_of_similarity(3.2) ).to eq 1
      expect( 3.14159.points_of_similarity(3.23) ).to eq 1
      expect( 3.14159.points_of_similarity(3.242) ).to eq 0
    end
  end

end