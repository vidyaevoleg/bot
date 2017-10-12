require "config"
require 'pry'
require 'capistrano/setup'

# Include default deployment tasks
require 'capistrano/deploy'
require 'capistrano/bundler'
require 'capistrano/bower'
require 'capistrano/rvm'
require 'capistrano3/unicorn'
require 'capistrano/rails/assets'
require 'capistrano/rails/migrations'

# Load custom tasks from lib/capistrano/tasks if you have any defined


production_settings_url = "./config/settings/production.yml"
Config.load_and_set_settings(production_settings_url)

Dir.glob('lib/capistrano/tasks/*.rake').each { |r| import r }
