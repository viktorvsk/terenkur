# # Stage vars
# # ======================
# set :application, 'terenkur-new'
# set :stage, :staging
# set :user, 'vvsk'
# set :deploy_env, 'staging'
# set :rails_env, 'production'
# #set :host, '54.68.36.220'
# set :rvm_type, :user
# set :rvm_ruby_version, '2.1.5'
# #set :port, 3097
# set :deploy_to, "/home/vvsk/#{fetch(:application)}"

# # Git branch
# set :branch, 'master'

# # Extended Server Syntax
# # ======================
# server '54.68.36.220', roles: :all, user: fetch(:user)
