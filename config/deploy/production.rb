# Stage vars
# ======================
set :stage,       :production
set :deploy_env,  'production'
set :rails_env,   'production'

set :unicorn_pid, File.join(shared_path, 'tmp', 'pids', 'unicorn.pid')
set :unicorn_conf, File.join(current_path, 'config', 'unicorn', "#{fetch(:rails_env)}.rb")


# Extended Server Syntax
# ======================
server '54.68.36.220', roles: :all, user: fetch(:user)
