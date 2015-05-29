namespace :clone do
  task prod: :environment do
    puts "Working..."
    puts "New PGBackupsss"

    puts "Capturing new backup"
    `heroku pg:backups capture --app planit-app`
    puts "Captured the production database"

    url = `heroku pg:backups public-url --app planit-app`.split(" ").last.strip
    `curl -o latest.dump "#{url}"`
    
    puts "Stored a local copy"
    `pg_restore --verbose --clean --no-acl --no-owner -h localhost -U #{ Env.db_owner } -d planit_development latest.dump`
    
    puts "Local database restored"
    `rm latest.dump`
  end
end