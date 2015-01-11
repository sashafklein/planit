class AddWifiTimezoneStringMenuMobileMenuFourSquareIdScrapeUrlToPlaces < ActiveRecord::Migration
  def change
    add_column :places, :wifi, :boolean, default: false
    add_column :places, :menu, :string
    add_column :places, :mobile_menu, :string
    add_column :places, :foursquare_id, :string
    add_column :places, :scrape_url, :string
    add_column :places, :timezone_string, :string
  end
end
