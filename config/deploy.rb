# set :application, "set your application name here"
# set :repository,  "set your repository location here"
# 
# set :scm, :subversion
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

#role :web, "your web-server here"                          # Your HTTP server, Apache/etc
#role :app, "your app-server here"                          # This may be the same as your `Web` server
#role :db,  "your primary db-server here", :primary => true # This is where Rails migrations will run
#role :db,  "your slave db-server here"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
# namespace :deploy do
#   task :start do ; end
#   task :stop do ; end
#   task :restart, :roles => :app, :except => { :no_release => true } do
#     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
#   end
# end

$:.unshift(File.expand_path('./lib', ENV['rvm_path']))
require "rvm/capistrano"
 
# REPLACE this below with your ruby version/gemset version:  YOUR_RUBY_VERSION@YOUR_GEM_SET
set :rvm_ruby_string, 'ruby-1.9.2-p318'
set :rvm_type, :user

default_run_options[:pty] = true
set :use_sudo, false
set :stages, %w(production staging)
set :default_stage, "staging"
require 'capistrano/ext/multistage'
 
# REPLACE this below with your git repo
set :repository,  "git@github.com:dbachet/test_to_linode.git"
set :scm, :git
set :branch, "master"
set :deploy_via, :remote_cache
 
# REPLACE the below with your deploy server credentials/server domain name (or ip)
set :user, 'daf'
set :port, 3456
server "changeons.org", :app, :web, :db, :primary => true
 
after "deploy:update_code",
  "deploy:update_shared_symlinks"
 
set :bundle_flags, '--deployment'
require "bundler/capistrano"
 
after "bundle:install",
  "deploy:migrate"
 
after "deploy",
  "deploy:cleanup"
 
namespace :deploy do
  task :start do ; end
  task :stop  do ; end
 
  # This task with bounce the standalone passenger server (running the embedded nginx server).
  # The rails_env and passenger_port are specified in the deploy environment files, ex: "config/deploy/staging.rb"
  desc "Restart Passenger server"
  task :restart, :roles => :app, :except => { :no_release => true } do
    run <<-CMD
      if [[ -f #{release_path}/tmp/pids/passenger.#{passenger_port}.pid ]];
      then
        cd #{deploy_to}/current && passenger stop -p #{passenger_port} --pid-file #{release_path}/tmp/pids/passenger.#{passenger_port}.pid;
      fi
    CMD
    # restart passenger standalone on the specified port/environment and as a daemon
    run "cd #{deploy_to}/current && #{try_sudo} passenger start -e #{rails_env} -p #{passenger_port} -d"
  end
 
  desc "Update shared symbolic links"
  task :update_shared_symlinks do
    shared_files = ["config/database.yml"]
    shared_files.each do |path|
      run "rm -rf #{File.join(release_path, path)}"
      run "ln -s #{File.join(deploy_to, "shared", path)} #{File.join(release_path, path)}"
    end
  end
end