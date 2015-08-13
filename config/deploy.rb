# config valid only for current version of Capistrano
lock '3.4.0'

set :application, 'inte-ensimag'
set :repo_url, '/var/git/inte-ensimag'

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, '/srv/inte-ensimag'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/secrets.yml')

# Default value for linked_dirs is []
set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp', 'vendor/bundle', 'node/node_modules', 'node/tmp')

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
set :keep_releases, 3

# Fixes for mixed platform Gemfile.lock
set :bundle_flags, ''

task :remove_gemfile_lock do
  on roles(:all) do
    execute "rm -f #{release_path}/Gemfile.lock"
  end
end

before "bundler:install", "remove_gemfile_lock"