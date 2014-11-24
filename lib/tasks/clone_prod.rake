namespace :clone do
  task prod: :environment do
    `heroku pgbackups:capture`
    puts "Captured the production database"
    url = `heroku pgbackups:url`.strip
    `curl -o latest.dump "#{url}"`
    puts "Stored a local copy"
    `pg_restore --verbose --clean --no-acl --no-owner -h localhost -U #{ENV['DB_OWNER']} -d planit_development latest.dump`
    puts "Local database restored"
    `rm latest.dump`
  end
end