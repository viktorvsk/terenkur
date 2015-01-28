# config valid only for Capistrano 3.2.1
lock '3.2.1'

# repo vars
set :scm,               :git
set :repo_url,          'git@bitbucket.org:victorvsk/terenkur.git'
set :branch,            'master'
set :rvm_type,            :user
set :rvm_ruby_version,  '2.1.5'
set :user,              'vvsk'
set :application,       'terenkur-new'
set :deploy_to,         "/home/#{fetch(:user)}/#{fetch(:application)}"
# output format
set :format,            :pretty
set :log_level,         :info #:debug

# Default value for :linked_files is []
set :linked_files, %w{config/database.yml config/secrets.yml}

# Default value for linked_dirs is []
set :linked_dirs, %w{bin log pids tmp/pids public/uploads}

# Rails assets options
set :assets_roles, [:all]

# =========================
# Additional tasks
# =========================
set :default_env, { rvm_bin_path: '~/.rvm/bin' }
namespace :deploy do

  task :restart do
    invoke 'unicorn:legacy_restart'
  end

  desc 'Setup'
  task :setup do
    on roles(:all) do
      execute "mkdir -p #{shared_path}/config/"
      execute "mkdir -p #{shared_path}/socket/"
      upload!('shared/database.yml', "#{shared_path}/config/database.yml")
      upload!('shared/secrets.yml', "#{shared_path}/config/secrets.yml")
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :rake, "db:create"
        end
      end
    end
  end

  desc "Start unicorn"
  task :start do
    on roles(:all) do
      within release_path do
        execute "unicorn -c config/unicorn.rb  "
      end
    end
  end

  desc "Stop unicorn"
  task :stop do
    on roles(:all) do
      within release_path do
        #execute "./unicornd", :stop
      end
    end
  end

  desc "Restart unicorn"
  task :restart do
    on roles(:all) do
      within release_path do
        #execute "./unicornd", :restart
      end
    end
  end

  # task :restart do
  #   run "if [ -f #{unicorn_pid} ] && [ -e /proc/$(cat #{unicorn_pid}) ]; then kill -USR2 `cat #{unicorn_pid}`; else cd #{deploy_to}/current && bundle exec unicorn -c #{unicorn_conf} -E #{rails_env} -D; fi"
  # end
  # task :start do
  #   run "cd #{current_release} && bundle exec unicorn -c #{unicorn_conf} -E #{rails_env} -D"
  # end
  # task :stop do
  #   run "if [ -f #{unicorn_pid} ] && [ -e /proc/$(cat #{unicorn_pid}) ]; then kill -QUIT `cat #{unicorn_pid}`; fi"
  # end

  # desc 'Create symlink'
  # task :symlink do
  #   on roles(:all) do
  #     execute "rm -f #{release_path}/config/database.yml"
  #     execute "rm -f #{release_path}/config/secrets.yml"

  #     execute "ln -s #{shared_path}/config/database.yml #{release_path}/config/database.yml"
  #     execute "ln -s #{shared_path}/config/secrets.yml #{release_path}/config/secrets.yml"
  #   end
  # end

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

  # after :updating, :symlink

  before :setup, :starting
  before :setup, :updating
  before :setup, :install

  before 'deploy:assets:precompile', :disable_active_admin
  after 'deploy:assets:precompile', :enable_active_admin

end



# desc 'Restart application'
# task :restart do
#   on roles(:app), in: :sequence, wait: 5 do
#     sudo "restart #{application}"
#   end
# end


