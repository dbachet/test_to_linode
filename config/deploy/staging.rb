set :rails_env, "staging"
set :branch, "master"
set :application, "#{rails_env}.changeons.org"
set :deploy_to, "/home/daf/www/#{application}"
set :passenger_port, "3005"