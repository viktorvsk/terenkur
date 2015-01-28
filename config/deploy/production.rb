# Stage vars
# ======================
set :stage,       :production
set :deploy_env,  'production'
set :rails_env,   'production'

# Extended Server Syntax
# ======================
server '54.68.36.220', roles: :all, user: fetch(:user)
