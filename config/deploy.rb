# config valid only for Capistrano 3.2.1
lock '3.2.1'

# repo vars
set :scm,               :git
set :repo_url,          'git@bitbucket.org:victorvsk/terenkur.git'
set :branch,            'master'
set :rvm_type,           :user
set :rvm_ruby_version,  '2.1.5'
set :user,              'vvsk'
set :application,       'terenkur-new'
set :deploy_to,         "/home/#{fetch(:user)}/#{fetch(:application)}"
# output format
set :format,            :pretty
set :log_level,         :info

# Default value for :linked_files is []
set :linked_files, %w{config/database.yml config/secrets.yml}

# Default value for linked_dirs is []
set :linked_dirs, %w{bin log pids tmp/pids public/uploads}

# Rails assets options
set :assets_roles, [:all]

# =========================
# Additional tasks
# =========================
# set :default_env, { rvm_bin_path: '~/.rvm/bin' }
# set :default_env, { path: "~/.rvm/gems/ruby-2.1.5@default_env/bin:~/.rvm/bin:$PATH" }


namespace :deploy do

  desc "Start unicorn"
  task :start do
    on roles(:all) do
      within current_path do
        execute :bundle, "exec unicorn -c #{fetch(:unicorn_conf)} -E #{fetch(:rails_env)} -D"
      end
    end
  end

  desc "Stop unicorn"
  task :stop do
    on roles(:all) do
     execute "if [ -f #{fetch(:unicorn_pid)} ] && [ -e /proc/$(cat #{fetch(:unicorn_pid)}) ]; then kill -QUIT `cat #{fetch(:unicorn_pid)}`; fi"
    end
  end

  desc "Restart unicorn"
  task :restart do
    on roles(:all) do
      within release_path do
        invoke 'deploy:stop'
        invoke 'deploy:start'
      end
    end
  end

  desc 'Disable Active Admin'
  task :disable_active_admin do
    on roles(:all) do
      within release_path do
        execute "mv #{release_path}/app/admin/ #{release_path}/admin/"
      end
    end
  end

  desc 'Enable Active Admin'
  task :enable_active_admin do
    on roles(:all) do
      execute "mv #{release_path}/admin/ #{release_path}/app/admin/"
    end
  end

  after :finishing, :cleanup
  after :finishing, :restart

  before 'deploy:assets:precompile', :disable_active_admin
  after 'deploy:assets:precompile', :enable_active_admin

  after 'deploy:publishing', :restart

end