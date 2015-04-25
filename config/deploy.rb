# config valid only for Capistrano 3.2.1
lock '3.2.1'

# repo vars
set :scm,               :git
set :repo_url,          'git@bitbucket.org:ablebeam/terenkur.git'
set :branch,            'master'
set :rbenv_type,        :user
set :rbenv_ruby,        '2.2.2'
set :rbenv_map_bins,    %w{rake gem bundle ruby rails}
set :rbenv_roles,       :all
set :user,              'vvsk'
set :application,       'terenkur'
set :deploy_to,         "/home/#{fetch(:user)}/#{fetch(:application)}"
# output format
set :format,            :pretty
set :log_level,         :info

# Default value for :linked_files is []
set :linked_files, %w{config/database.yml config/secrets.yml}

# Default value for linked_dirs is []
set :linked_dirs, %w{bin log pids tmp/pids tmp/cache tmp/sockets vendor/bundle public/uploads public/assets}

# Rails assets options
set :assets_roles, [:all]

# =========================
# Additional tasks
# =========================
# set :default_env, { rvm_bin_path: '~/.rvm/bin' }
# set :default_env, { path: "~/.rvm/gems/ruby-2.1.5@default_env/bin:~/.rvm/bin:$PATH" }

namespace :db do
  # desc 'DB reset'
  # task :reset do
  #   on roles(:all) do
  #     within release_path do
  #       with rails_env: 'production' do

  #         invoke 'active_admin:disable'
  #         begin
  #           execute :bundle, "exec rake db:reset"
  #         ensure
  #           invoke 'active_admin:enable'
  #         end

  #       end
  #     end
  #   end
  # end

  desc 'DB seed'
  task :seed do
    on roles(:all) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :bundle, "exec rake db:seed"
        end
      end
    end
  end

  desc 'DB migrate'
  task :migrate do
    on roles(:all) do
      within release_path do
        with rails_env: fetch(:rails_env) do

          invoke 'active_admin:disable'
          begin
            execute :bundle, "exec rake db:migrate"
          ensure
            invoke 'active_admin:enable'
          end

        end
      end
    end
  end

  desc 'DB rollback'
  task :rollback do
    on roles(:all) do
      within release_path do
        with rails_env: fetch(:rails_env) do

          invoke 'active_admin:disable'
          begin
            execute :bundle, "exec rake db:rollback"
          ensure
            invoke 'active_admin:enable'
          end

        end
      end
    end
  end
end

namespace "active_admin" do
  desc 'Disable Active Admin'
  task :disable do
    on roles(:all) do
      within release_path do
        execute "mv #{release_path}/app/admin/ #{release_path}/admin/"
      end
    end
  end

  desc 'Enable Active Admin'
  task :enable do
    on roles(:all) do
      execute "mv #{release_path}/admin/ #{release_path}/app/admin/"
    end
  end
end


namespace :sitemap do
  desc "Generate Sitemap"
  task :generate do
    on roles(:all) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :rake, 'sitemap:generate'
        end
      end
    end
  end

  desc "Symlink Sitemap"
  task :symlink do
    on roles(:all) do
      execute "rm -f #{release_path}/public/sitemap.xml"
      execute "ln -s #{release_path}/public/sitemaps/sitemap.xml #{release_path}/public/sitemap.xml"
    end
  end
end

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

  desc "Setup"
  task :setup do
    on roles(:all) do
      upload! 'shared/secrets.yml', "#{shared_path}/config/secrets.yml"
      upload! 'shared/database.yml', "#{shared_path}/config/database.yml"
      upload! 'shared/nginx.conf', "#{shared_path}/config/nginx.conf"
      upload! 'shared/terenkur.conf', "#{shared_path}/config/terenkur.conf"
    end
  end

  after :finishing, :cleanup
  after :finishing, :restart

  before 'deploy:migrate', 'active_admin:disable'
  after 'deploy:migrate', 'active_admin:enable'

  after 'publishing', :restart
  # after 'publishing', 'sitemap:generate'
  # after 'publishing', 'sitemap:symlink'

end
