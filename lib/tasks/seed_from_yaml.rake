namespace :seed  do
  task from_test_yml: :environment do
    TaskRunners::FromTestYml.new.seed
  end
end