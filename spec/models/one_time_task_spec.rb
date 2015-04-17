require 'rails_helper'

describe OneTimeTask do

  describe 'execute' do
    it "executes the first time for a unique hash and never again" do
      value = 1
      5.times do
        OneTimeTask.execute(detail: 'Unique') do
          value += 1
        end
      end

      expect( value ).to eq 2
    end

    it "doesn't compare the extras hash for uniqueness" do
      value = 1

      1.upto(5).each do |num|
        OneTimeTask.execute(detail: 'Unique', extras: { notUnique: num } ) do
          value += 1
        end
      end

      expect( value ).to eq 2
    end

    it "doesn't need a block" do
      expect{ OneTimeTask.execute(detail: 'Whatever') }.not_to raise_error
    end

    it "can be associated with model objects" do
      value = 1
      user = create(:user)
      place = create(:place)

      1.upto(5).each do |num|
        OneTimeTask.execute(detail: 'Unique', agent: user, target: place, extras: { notUnique: num } ) do
          value += 1
        end
      end

      expect( value ).to eq 2

      expect( OneTimeTask.count ).to eq 1
      expect( user.one_time_tasks.where(detail: 'Unique').first ).to be_a OneTimeTask
      expect( place.one_time_tasks.first ).to eq user.one_time_tasks.first

      expect{ 
        OneTimeTask.execute(detail: 'Unique', agent: create(:user), target: place)
      }.to change{ OneTimeTask.count }.by 1
    end

    describe "polymorphic relations" do
      it "anything can be a target" do
        expect{
          OneTimeTask.execute(agent: create(:user), target: create(:plan))
        }.not_to raise_error
      end

      it "users can be targets too" do
        expect{
          OneTimeTask.execute(agent: create(:user), target: create(:user))
        }.not_to raise_error
      end
    end

  end

  describe "has?" do
    it "returns true or false depending on the tasks existence" do
      expect( OneTimeTask.has?(detail: 'Something') ).to eq false
      OneTimeTask.execute(detail: 'Something')
      expect( OneTimeTask.has?(detail: 'Something') ).to eq true
    end
  end

end
