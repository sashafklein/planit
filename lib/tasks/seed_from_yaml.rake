namespace :seed  do
  task from_test_yml: :environment do
    TaskRunners::FromTestYml.new.seed
  end

  task remove_log: :environment do
    `rm lib/task_runners/log/from_test_yml.txt`
  end
end