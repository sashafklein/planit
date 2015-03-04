require 'rails_helper'

describe Api::V1::BookmarkletsController do

  describe "error" do
    it "shoots off a (delayed) email" do
      expect( AdminMailer ).to receive(:bookmarklet_failure).twice.with('1', 'whatever.com').and_call_original
      get :error, user_id: 1, url: 'whatever.com'
      expect( Delayed::Job.count ).not_to eq 0
      Delayed::Worker.new.work_off 1
      expect( ActionMailer::Base.deliveries.count ).to eq 1
      expect( ActionMailer::Base.deliveries.first.subject ).to eq "Bookmarklet Failure"
    end
  end

  describe "test" do
    describe "with a preexisting mark for that source" do

      before do
        @user = create(:user)
        @url = "http://www.nytimes.com/some-article?r=bullshit"
      end
      
      context "associated with the user" do

        before do
          @mark = create(:mark, user: @user)
          @source = @mark.create_source!(source_url: @url)
        end

        it "doesn't create another mark or source, but does return the mark id" do
          source_count = Source.count
          mark_count = Mark.count
          place_count = Place.count

          get :test, url: @url, user_id: @user.id

          expect( source_count ).to eq Source.count
          expect( mark_count ).to eq Mark.count
          expect( place_count ).to eq Place.count

          expect( response_body.mark_id ).to eq @mark.id
        end
      end

      context "associated with another user" do

        before do
          @user2 = create(:user)
          @mark = create(:mark, user: @user2)
          @source = @mark.create_source!(source_url: @url)
        end

        context "with a place chosen" do
          it "builds the user a new mark and source for the same place" do
            source_count = Source.count
            mark_count = Mark.count
            place_count = Place.count
            user_marks_count = @user.marks.count
            
            get :test, url: @url, user_id: @user.id

            expect( source_count ).to eq Source.count - 1 
            expect( mark_count ).to eq Mark.count - 1
            expect( place_count ).to eq Place.count
            expect( user_marks_count ).to eq @user.marks.count - 1

            new_mark = @user.marks.first
            expect( response_body.mark_id ).to eq( new_mark.id )
            expect( @mark.place_id ).to eq new_mark.place_id
          end
        end

        context "with place_options, not a place" do
          it "creates a new mark for the user with duplicated place options" do
            @mark.update_attribute(:place_id, nil)
            expect( @mark.place ).to be_nil

            3.times{ create(:place_option, mark: @mark) }

            source_count = Source.count
            mark_count = Mark.count
            place_count = Place.count
            user_marks_count = @user.marks.count
            place_option_count = PlaceOption.count
            expect( place_option_count ).to eq 3

            get :test, url: @url, user_id: @user.id

            expect( Place.count ).to eq place_count
            expect( Mark.count ).to eq mark_count + 1
            expect( Source.count ).to eq source_count + 1
            expect( @user.marks.count ).to eq user_marks_count + 1
            expect( PlaceOption.count ).to eq place_option_count + 3
            expect( @mark.place_options.map(&:name).sort ).to eq @user.marks.first.place_options.map(&:name).sort
          end
        end

        context "with multiple marks, some with place, some not" do
          it "prioritizes the one with the place" do
            user3 = create(:user)
            mark2 = create(:mark, user: user3, place: nil)
            mark2.create_source!(source_url: @url)

            3.times{ create(:place_option, mark: mark2) }

            expect{
              get :test, url: @url, user_id: @user.id
            }.to change{ @user.marks.count }.from(0).to(1) 

            expect( @user.marks.first.place_id ).to eq @mark.place_id
            expect( PlaceOption.count ).to eq 3
          end
        end
      end
    end
  end
end