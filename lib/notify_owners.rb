puts "Send notification to system owners about inactive roles if any"

permissions = Permission.all
permissions.each do |permission|
  owner = User.find(permission.user_id)
  roles = Role.where(system_id: permission.system_id)
  roles.each do |role|
    UserMailer.role_inactive(role, owner).deliver_now if !role.is_active
  end
end