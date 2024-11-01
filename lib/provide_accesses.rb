if Rails.env.development?
  puts 'This task must not run in development mode'
  abort
end

start_time = Time.now
roles = Role.where(is_active: true)
RoleValidationService.run(roles)


roles = Role.where(is_active: true)
roles.each do |role|
  begin
    AccessProvisionService.run(role)
  rescue Net::LDAP::Error => e  # Replace with your LDAP error class if different
    Rails.logger.debug("LDAP timeout encountered for '#{role.name}' role in '#{role.system.name}' system: #{e}")
    next
  rescue => e
    Rails.logger.debug("Access provision failed for '#{role.name}' role in '#{role.system.name}' system: #{e} ")
    role.update(is_active: false)
    next
  end
end
end_time = Time.now

execution_time_in_minutes = (end_time - start_time) / 60.0
puts "Execution time: #{execution_time_in_minutes.round(2)} minutes"