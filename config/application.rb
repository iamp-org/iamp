require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_mailbox/engine"
require "action_text/engine"
require "action_view/railtie"
require "action_cable/engine"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Iamp
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.1

    # Use background jobs
    config.active_job.queue_adapter = :sidekiq

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # Don't generate system test files.
    config.generators.system_tests = nil

    # Active Directory configuration
    config.ldap_host                        = ENV.fetch("LDAP_HOST") { "ldap.dummy.host" }
    config.ldap_port                        = ENV.fetch("LDAP_PORT") { 636 }
    config.ldap_base                        = ENV.fetch("LDAP_BASE") { "ldap.dummy.base" }
    config.ldap_username                    = ENV.fetch("LDAP_USERNAME") { "ldap.dummy.username" }
    config.ldap_password                    = ENV.fetch("LDAP_PASSWORD") { "ldap.dummy.password" }
    config.ldap_user_accounts_filter        = ENV.fetch("LDAP_USER_ACCOUNTS_FILTER") { "(&(objectCategory=Person)(!(UserAccountControl:1.2.840.113556.1.4.803:=2)))" }
    config.ldap_service_accounts_filter     = ENV.fetch("LDAP_SERVICE_ACCOUNTS_FILTER") { "(&(objectCategory=Person)(!(UserAccountControl:1.2.840.113556.1.4.803:=2)))" }
    
    config.ldap_user_accounts_searchbase    = [
      "OU=Internal Users,OU=Accounts and Groups,#{config.ldap_base}",
      "OU=External Users,OU=Accounts and Groups,#{config.ldap_base}"
    ]
    config.ldap_service_accounts_searchbase = [
      "OU=Service Accounts,OU=Accounts and Groups,#{config.ldap_base}",
      "OU=Accounts,OU=Admin accounts,#{config.ldap_base}"
    ]
    config.ldap_user_attributes_mapping     = {
      id:           :objectGUID,
      displayname:  :displayName,
      username:     :sAMAccountName,
      dn:           :dn,
      company:      :company,
      position:     :title,
      team:         :department,
      email:        :userPrincipalName,
      manager_id:   :manager
    }

    # SMTP configuration
    config.action_mailer.delivery_method = :smtp
    config.action_mailer.default_url_options = { host: ENV.fetch("HOSTNAME") { "ldap.dummy.host" } }
    config.action_mailer.smtp_settings = {
      :address              => ENV.fetch("SMTP_ADDRESS") { "ldap.dummy.address" },
      :port                 => 587,
      :user_name            => ENV.fetch("SMTP_USERNAME") { "ldap.dummy.username" },
      :password             => ENV.fetch("SMTP_PASSWORD") { "ldap.dummy.passport" },
      :authentication       => :login,
      :enable_starttls      => true,
      :open_timeout         => 60,
      :read_timeout         => 120
    }

  end
end
