puts "Users sync"
ldap = LdapService.new(
  Rails.application.config.ldap_host, 
  Rails.application.config.ldap_port,
  Rails.application.config.ldap_base
  )
if ldap.authenticate(
  Rails.application.config.ldap_username,
  Rails.application.config.ldap_password
  )
  # Synchronize user accounts
  ldap.sync_users(
    Rails.application.config.ldap_user_accounts_searchbase,
    Rails.application.config.ldap_user_accounts_filter,
    Rails.application.config.ldap_user_attributes_mapping
  )
  # Synchronize service accounts
  ldap.sync_users(
    Rails.application.config.ldap_service_accounts_searchbase,
    Rails.application.config.ldap_service_accounts_filter,
    Rails.application.config.ldap_user_attributes_mapping,
    is_service: true
  )
end