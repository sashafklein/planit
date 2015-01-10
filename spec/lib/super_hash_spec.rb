require 'spec_helper'

describe SuperHash do
  describe "access" do
    it "has indifferent and method access" do
      sh = SuperHash.new({ one: 1 })

      expect(  sh.one   ).to eq 1
      expect( sh['one'] ).to eq 1
      expect(  sh[:one] ).to eq 1

      sh.two = 2
      expect(  sh.two   ).to eq 2
      expect( sh['two'] ).to eq 2
      expect( sh[:two]  ).to eq 2
      
      sh.two = '2'
      expect(  sh.two   ).to eq '2'
      expect( sh['two'] ).to eq '2'

      sh['two'] = 2
      expect( sh.two ).to eq 2

      expect( sh.to_h ).to eq({ 'one' => 1, 'two' => 2 })
    end
  end

  describe "fetch" do

    before { initialize_sh }

    it "can take a splat list search terms, indifferently" do
      expect( @sh.super_fetch(:super_deep, :deepest, :value, 2).recursive_symbolize_keys ).to eq({another_hash: { value: 'buried' } })
      expect( @sh.super_fetch('super_deep', 'deepest', 'value', 2).recursive_symbolize_keys ).to eq({another_hash: { value: 'buried' } })
    end

    it "can take a single search term" do
      expect( @sh.super_fetch(:shallowest) ).to eq 1
      expect( @sh.super_fetch('shallowest') ).to eq 1
    end

    it "can take an array of search terms" do
      expect( @sh.super_fetch([:super_deep, :deepest, :value, 2]).recursive_symbolize_keys ).to eq({another_hash: { value: 'buried' } })
      expect( @sh.super_fetch(['super_deep', 'deepest', 'value', 2]).recursive_symbolize_keys ).to eq({another_hash: { value: 'buried' } })
    end

    it "can defaults to nil if nothing's there" do
      expect( @sh.super_fetch(:shallowest, :nonexistent) ).to eq nil
      expect( @sh.super_fetch(:shallowest, :nonexistent, :less_existent) ).to eq nil
    end

    it 'can take a default block' do
      expect( @sh.super_fetch(:shallowest, :nonexistent) { 'default_return' }).to eq 'default_return'
      expect{ @sh.super_fetch(:shallowest, :nonexistent) { |key| raise("No such key: #{key}") } }.to raise_error "No such key: nonexistent"
    end
  end

  describe '[]' do

    before { initialize_sh }
    
    it "works like a regular (indifferent) hash" do
      expect( @sh[:nonexistent] ).to eq nil
      expect( @sh[:shallowest] ).to eq 1
      expect( @sh['nonexistent']).to eq nil
      expect( @sh['shallowest']).to eq 1
      expect( @sh.nonexistent ).to eq nil
    end
  end

  def initialize_sh
    @sh = SuperHash.new({
      shallowest: 1,
      super_deep: {
        shallow: 1,
        deepest: {
          value: [ 1, 2, another_hash: { value: 'buried' }]
        } 
      }
    })
  end
end