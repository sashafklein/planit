class AddTakesReservationReservationLinkToPlaces < ActiveRecord::Migration
  def change
    add_column :places, :reservations, :boolean, default: false
    add_column :places, :reservations_link, :string
  end
end
