require 'spec_helper'

module Services
  describe TimeConverter do

    describe '#convert' do

      it "converts 12 am" do
        expect( TimeConverter.new('12 am').absolute ).to eq "0000"
      end

      it "converts 12 a.m." do
        expect( TimeConverter.new('12 a.m.').absolute ).to eq "0000"
      end

      it "converts 12 a.m" do
        expect( TimeConverter.new('12 a.m').absolute ).to eq "0000"
      end

      it "converts 12:00 am" do
        expect( TimeConverter.new('12 am').absolute ).to eq "0000"
      end

      it "converts 12:00AM" do
        expect( TimeConverter.new('12AM').absolute ).to eq "0000"
      end

      it "converts 12:00 pm" do
        expect( TimeConverter.new('12:00 pm').absolute ).to eq "1200"
      end

      it "converts 12:30 pm" do
        expect( TimeConverter.new('12:30 pm').absolute ).to eq "1230"
      end

      it "converts 6:39" do
        expect( TimeConverter.new('6:39').absolute ).to eq "0639"
      end

      it "converts 6:39pm" do
        expect( TimeConverter.new('6:39pm').absolute ).to eq "1839"
      end

      it "converts 18:39" do
        expect( TimeConverter.new('18:39').absolute ).to eq "1839"
      end

      it "converts 00" do
        expect( TimeConverter.new('00').absolute ).to eq '0000'
      end

      it "converts 1 pm" do
        expect( TimeConverter.new('1 pm').absolute ).to eq '1300'
      end

      it "converts 1:30pm" do
        expect( TimeConverter.new('1:30pm').absolute ).to eq '1330'
      end

      it "converts 2400pm" do
        expect( TimeConverter.new('2400').absolute ).to eq '0000'
      end

      it "converts 01:30 am" do
        expect( TimeConverter.new('1:30 am').absolute ).to eq '0130'
      end

      it "converts 0030" do
        expect( TimeConverter.new('0030').absolute ).to eq '0030'
      end

      it "converts 2330" do
        expect( TimeConverter.new('2330').absolute ).to eq '2330'
      end

      it "converts 2330" do
        expect( TimeConverter.new(23).absolute ).to eq '2300'
      end

      it "errors for 25:34" do
        expect{ TimeConverter.new('25:34').absolute }.to raise_error
      end

      it "errors for 12:64" do
        expect{ TimeConverter.new('12:64').absolute }.to raise_error
      end
    end

    describe "#am_pm" do
      it "shows 12 am correctly" do
        expect( TimeConverter.new('12 am').am_pm ).to eq "12:00 am"
      end

      it "shows 12 a.m. correctly" do
        expect( TimeConverter.new('12 a.m.').am_pm ).to eq "12:00 am"
      end

      it "shows 12 a.m correctly" do
        expect( TimeConverter.new('12 a.m').am_pm ).to eq "12:00 am"
      end

      it "shows 12:00 am correctly" do
        expect( TimeConverter.new('12 am').am_pm ).to eq "12:00 am"
      end

      it "shows 12:00AM correctly" do
        expect( TimeConverter.new('12AM').am_pm ).to eq "12:00 am"
      end

      it "shows 12:00 pm correctly" do
        expect( TimeConverter.new('12:00 pm').am_pm ).to eq "12:00 pm"
      end

      it "shows 12:30 pm correctly" do
        expect( TimeConverter.new('12:30 pm').am_pm ).to eq "12:30 pm"
      end

      it "shows 6:39 correctly" do
        expect( TimeConverter.new('6:39').am_pm ).to eq "6:39 am"
      end

      it "shows 6:39pm correctly" do
        expect( TimeConverter.new('6:39pm').am_pm ).to eq "6:39 pm"
      end

      it "shows 18:39 correctly" do
        expect( TimeConverter.new('18:39').am_pm ).to eq "6:39 pm"
      end

      it "shows 00 correctly" do
        expect( TimeConverter.new('00').am_pm ).to eq '12:00 am'
      end

      it "shows 1 pm correctly" do
        expect( TimeConverter.new('1 pm').am_pm ).to eq '1:00 pm'
      end

      it "shows 1:30pm correctly" do
        expect( TimeConverter.new('1:30pm').am_pm ).to eq '1:30 pm'
      end

      it "shows 01:30 am correctly" do
        expect( TimeConverter.new('1:30 am').am_pm ).to eq '1:30 am'
      end
    end

    describe '.convert_hours' do
      it "converts a straightforward hash" do
        hours = {
          'mon' => { 
            'start_time' => '10:00 pm',
            'end_time' => '11pm'
          },
          tue: { 
            start_time: '2320',
            end_time: '12AM'
          }
        }
        expect( TimeConverter.convert_hours(hours) ).to hash_eq({
          mon: [ ['2200', '2300' ] ],
          tue: [ ['2320', '0000' ] ]
        })
      end

      it "converts a split time hash" do
        hours = {
          'mon' => [{ 
           'start_time' => '9:00 am',
            'end_time' => '11am'
          },{
            'start_time' => '12pm',
            'end_time' => '5pm'
          }],
          tue: [{ 
            start_time: '2320',
            end_time: '12AM'
          }]
        }
        expect( TimeConverter.convert_hours(hours) ).to hash_eq({
          mon: [ ['0900', '1100'], ['1200', '1700'] ],
          tue: [ ['2320', '0000'] ]
        })
      end

      it "converts a hash with date spreads" do
        hours = {
          'mon-thu' => [{
            'start_time' => '8',
            'end_time' => '23'
          }],
          'fri' => [{ 
            start_time: '9am',
            end_time: '2400'
          }],
          :'sat-sun' => [{
            start_time: 10,
            end_time: 12
          },
          {
            start_time: 13,
            end_time: 23
          }
          ]
        }

        expect( TimeConverter.convert_hours(hours) ).to hash_eq({
          mon: [ ['0800', '2300'] ],
          tue: [ ['0800', '2300'] ],
          wed: [ ['0800', '2300'] ],
          thu: [ ['0800', '2300'] ],
          fri: [ ['0900', '0000'] ],
          sat: [ ['1000', '1200'], ['1300', '2300'] ],
          sun: [ ['1000', '1200'], ['1300', '2300'] ]
        })
      end

      it 'converts the new array format' do
        hours = {
          'mon-thu' => [['8','23']],
          fri: [['9am','2400']],
          :'sat-sun' => [[10,12],[13,23]]
        }

        expect( TimeConverter.convert_hours(hours) ).to hash_eq({
          mon: [ ['0800', '2300'] ],
          tue: [ ['0800', '2300'] ],
          wed: [ ['0800', '2300'] ],
          thu: [ ['0800', '2300'] ],
          fri: [ ['0900', '0000'] ],
          sat: [ ['1000', '1200'], ['1300', '2300'] ],
          sun: [ ['1000', '1200'], ['1300', '2300'] ]
        })
      end
    end

    describe ".hours_converted?" do
      it "returns true for good hours" do
        hours = { 'mon' => [[ '2200', '2300' ]] }
        expect( TimeConverter.hours_converted?(hours) ).to eq true
      end

      it 'returns false for incomplete hours' do
        hours = { 'mon' => [[ '2200' ]] }
        expect( TimeConverter.hours_converted?(hours) ).to eq false
      end

      it "returns false for badly formatted hours" do
        hours = { 'mon' => [[ '2200', '11pm' ]] }
        expect( TimeConverter.hours_converted?(hours) ).to eq false
      end

      it 'returns false for hours with bad keys' do
        hours = {'mon-fri' => [[ '2000', '2200' ]] }
        expect( TimeConverter.hours_converted?(hours) ).to eq false
      end
    end
  end
end