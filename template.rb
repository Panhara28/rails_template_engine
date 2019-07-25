def source_paths
  [File.expand_path(File.dirname(__FILE__))]
end

def add_gems
  gem 'devise'
  gem 'bulma-rails'
  gem 'sidekiq'
  gem_group :development, :test do
    gem 'better_errors'
    gem 'guard'
    gem 'guard-livereload'
  end
end

def set_application_name
  application_name = ask("What is your application name ? Default: RailsTemplate")

  application_name = application_name.present? ? application_name : "RailsTemplate"

  environment  "config.application_name = '#{application_name}'"

  puts "Your Application name is #{application_name}. You can change this later on ./config/application.rb"
end

def add_users
  generate "devise:install"

  environment  "config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }", env: "development"

  route "root 'home#index'"

  generate :devise, "User", "name"
end

def remove_app_css
  run "rm app/assets/stylesheets/application.css"
end

def copy_template
  directory "app", force: true
end

def add_sidekiq
  environment  "config.active_job.queue_adapter = :sidekiq"

  insert_into_file "config/routes.rb",
    "require 'sidekiq/web'\n\n ",
    before: "Rails.application.routes.draw do"
end

def add_home

end

def init_guardfile
  run "guard init livereload"
end

add_gems

after_bundle do
  set_application_name
  add_home
  add_users
  remove_app_css
  add_sidekiq
  init_guardfile

  copy_template

  rails_command "db:create"
  rails_command "db:migrate"

  git :init
  git add: "."
  git commit: %Q{ -m "Initial Commit" }
end
