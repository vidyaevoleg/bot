lock '3.4.0'

set :application, 'bot'
set :repo_url, 'git@github.com:vidyaevoleg/bot.git'
set :ssh_options, { :forward_agent => true }
set :deploy_to, '/var/www/bot'
set :app_root, fetch(:deploy_to) + '/current'
set :sidekiq_pid, "#{fetch(:app_root)}/tmp/pids/sidekiq.pid"
set :stage_env, :production
set :branch, 'master'
set :_linked_files, %w(
  config/database.yml
  config/sidekiq.yml
  config/secrets.yml
  config/redis.yml
  config/settings/production.yml
)
set :_linked_dirs, %w(
  .bundle
  tmp/pids
  tmp/cache
  tmp/sockets
  log
  vendor/bundle
  public/system
  public/uploads
)

set :linked_files, fetch(:linked_files, []).concat(fetch(:_linked_files))
set :linked_dirs, fetch(:linked_dirs, []).concat(fetch(:_linked_dirs))
set :format, :pretty
set :log_level, :info
set :assets_roles, [:web, :app]
set :normalize_asset_timestamps, %{public/images public/javascripts public/stylesheets}
set :bower_bin, "/usr/local/bin/bower"
set :runner, Settings.deploy_user

namespace :bower do
  desc 'Install bower'
  task :setup do
    on roles(:web) do
      within release_path do
        invoke "bower:install"
      end
    end
  end
end

namespace :sidekiq do
  desc 'Start sidekiq'
  task :start do
    on roles(:workers) do
      as fetch(:runner) do
        within(fetch(:app_root)) do
          with(path: "/opt/ruby/bin/:$PATH", rails_env: fetch(:stage_env)) do
            if test(:test, "-f #{fetch(:sidekiq_pid)} -a -e /proc/$(cat #{fetch(:sidekiq_pid)})")
              execute :kill, "-SIGHUP $(cat #{fetch(:sidekiq_pid)})"
            end
            execute :bundle, "exec sidekiq start --daemon"
          end
        end
      end
    end
  end

  desc 'Stop sidekiq'
  task :stop do
    on roles(:workers) do
      as fetch(:runner) do
        within(fetch(:app_root)) do
          with(path: "/opt/ruby/bin/:$PATH", rails_env: fetch(:stage_env)) do
            if test(:test, "-f #{fetch(:sidekiq_pid)} -a -e /proc/$(cat #{fetch(:sidekiq_pid)})")
              execute :kill, "-USR1 $(cat #{fetch(:sidekiq_pid)})"
            end
          end
        end
      end
    end
  end

  desc 'Restart sidekiq'
  task :restart do
    on roles(:workers) do
      as fetch(:runner) do
        within(fetch(:app_root)) do
          with(path: "/opt/ruby/bin/:$PATH", rails_env: fetch(:stage_env)) do
            invoke "sidekiq:stop"
            invoke "sidekiq:start"
          end
        end
      end
    end
  end
end


before "deploy:compile_assets", "bower:setup"
# before :deploy, 'settings:setup'
after 'deploy:publishing', 'deploy:restart'
after :deploy, 'unicorn:restart'
after :deploy, 'sidekiq:restart'
