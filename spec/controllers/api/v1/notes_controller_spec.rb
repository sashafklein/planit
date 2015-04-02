require 'rails_helper'

describe Api::V1::NotesController do
  describe "create" do

    before do 
      @user = create(:user)
      @mark = create(:mark)
      @plan = create(:plan)
    end

    it "takes a body, object id, and object type and creates a note for the current user" do
      sign_in @user
      expect( Note.all.count ).to eq 0
      post :create, note: { object_id: @mark.id, object_type: 'Mark', body: 'Mark note' }
      post :create, note: { object_id: @plan.id, object_type: 'Plan', body: 'Plan note' }
      expect( Note.all.count ).to eq 2
      expect( @user.notes.count ).to eq 2
      expect( @user.notes.pluck(:object_type) ).to array_eq ['Mark', 'Plan']
      expect( @user.notes.pluck(:body) ).to array_eq ['Mark note', 'Plan note']
    end

    it "denies permission to non-users" do
      post :create, note: { object_id: @mark.id, object_type: 'Mark', body: 'Mark note' }

      expect( response.code ).to eq "403"
      expect( Note.count ).to eq 0
    end

  end
end