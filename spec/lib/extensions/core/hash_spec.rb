require 'spec_helper'

describe Hash do 
  describe "recursive_symbolize_keys" do
    it "symbolizes keys throughout the hash, without changing original" do
      hash = { 'key' => { 'key2' => { 'key3' => 3, key4: [ {'key5' => 5 }, 'whatever'] }}}
      expect(hash.recursive_symbolize_keys).to eq({ key: { key2: { key3: 3, key4: [ { key5: 5 }, 'whatever'] }}})
      expect(hash).to eq({ 'key' => { 'key2' => { 'key3' => 3, key4: [ {'key5' => 5 }, 'whatever'] }}})
    end
  end

  describe "recursive_symbolize_keys!" do
    it "symbolizes keys throughout the hash and changes original" do
      hash = { 'key' => { 'key2' => { 'key3' => 3, key4: [ {'key5' => 5 }, 'whatever'] }}}
      expect(hash.recursive_symbolize_keys!).to eq({ key: { key2: { key3: 3, key4: [ { key5: 5 }, 'whatever'] }}})
      expect(hash).to eq({ key: { key2: { key3: 3, key4: [ { key5: 5 }, 'whatever'] }}})
    end
  end

  describe "recursive_delete_if" do
    it "deletes the elements matching the block, deeply, without changing original" do
      hash = { true_key: true, nil_key: nil, hash: { true_key: true, nil_key: nil } }
      expect(hash.recursive_delete_if{ |k, v| v.nil?} ).to eq( { true_key: true, hash: { true_key: true } } )
      expect(hash).to eq( { true_key: true, nil_key: nil, hash: { true_key: true, nil_key: nil } } )
    end
  end

  describe "deep_val" do
    it "it indexes deep into array, and nil sinks by default" do
      hash = { a: { b: { c: 'd' }}}
      expect( hash.deep_val([:a, :b, :c]) ).to eq 'd'
      expect( hash.deep_val([:a, :e, :c]) ).to eq nil
        expect( hash.deep_val([:a, :e, :c], '') ).to eq ''
    end
  end
end