server "#{Settings.deploy_server}", user: "#{Settings.deploy_user}", roles: [:app, :db, :web, :workers]
set :unicorn_rack_env, -> { "production" }
