namespace :cron do
  task clean_old_place_options: :environment do
    PlaceOption.clean_old!
  end
end