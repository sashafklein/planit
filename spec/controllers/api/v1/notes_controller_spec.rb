require 'rails_helper'

describe Api::V1::NotesController do
  describe "api" do

    before do 
      @user = create(:user)
      @mark = create(:mark)
      @plan = create(:plan)
    end

    describe "creates" do
      it "note with a body, obj id, and obj type -- for the current user" do
        sign_in @user
        expect( Note.all.count ).to eq 0
        post :create, note: { obj_id: @mark.id, obj_type: 'Mark', body: 'Mark note' }
        post :create, note: { obj_id: @plan.id, obj_type: 'Plan', body: 'Plan note' }
        expect( Note.all.count ).to eq 2
        expect( @user.notes.count ).to eq 2
        expect( @user.notes.pluck(:obj_type) ).to array_eq ['Mark', 'Plan']
        expect( @user.notes.pluck(:body) ).to array_eq ["Plan note", "Mark note"]
      end

      it "but denies permission to non-users" do
        post :create, note: { obj_id: @mark.id, obj_type: 'Mark', body: 'Mark note' }

        expect( response.code ).to eq "403"
        expect( Note.count ).to eq 0
      end
    end

    describe "finds" do

      before do
        @item = create(:item)
        @note = create(:note, obj: @item)
      end

      it "an item's notes" do
        get :find_by_object, { obj_id: @item.id, obj_type: @item.class }
        expect( response_body.body ).to eq "Yo bitch that was insane"
      end
    end
  end
end