module ApplicationHelper
  def current_user_has_write_permission_for_role?(role)
    current_user.permissions.exists?(system_id: role.system_id) || current_user.is_admin?
  end

  def current_user_is_admin_or_has_any_system?
    current_user.permissions.exists? || current_user.is_admin?
  end
end
