if Rails.env.development?
  puts 'This task must not run in development mode'
  abort
end

puts "Revoke accesses"
# Revoke accesses of disabled users
disabled_users = User.where(is_active: false)
disabled_users.each do |disabled_user|
  accesses = Access.where(user_id: disabled_user.id)
  if accesses.present?
    accesses.each do |access|
      AuditLog.create(
        system_id:          access.role.system.id,
        event_type:         :access_revoked,
        event_description:  "Access revoked due to dismissal. User: #{access.user.displayname}. System: #{access.role.system.name}. Role: #{access.role.name}"
      )
      role = access.role # for Trigger IAM job
      access.destroy
      TriggerIamJob.perform_later(role)
    end
  end
end

# Revoke expired accesses
expired_accesses = Access.where('expires_at < ?', DateTime.now)
expired_accesses.each do |access|
  AuditLog.create(
    system_id:          access.role.system.id,
    event_type:         :access_revoked,
    event_description:  "Access revoked due to expiration. User: #{access.user.displayname}. System: #{access.role.system.name}. Role: #{access.role.name}"
  )
  UserMailer.access_revoked(access, "Access has expired").deliver_later
  role = access.role # for Trigger IAM job
  access.destroy
  TriggerIamJob.perform_later(role)
end