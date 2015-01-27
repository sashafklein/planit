namespace :clone do
  task prod: :environment do
    puts "Working..."

    puts "Looking at previous backups"
    output = `heroku pgbackups`.split("\nb")
    oldest_backup_number = "b" + output[1].split("  ")[0]
    
    puts "Deleting oldest backup to make room"
    `heroku pgbackups:destroy #{oldest_backup_number}`

    puts "Capturing new backup"
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