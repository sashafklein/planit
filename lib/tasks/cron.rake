namespace :cron do
  task clean_old_place_options: :environment do
    PlaceOption.clean_old!
  end

  task clean_dead_images: :environment do
    Image.trim_dead!
  end
end