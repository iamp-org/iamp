class RoleValidationService
  # Validate roles configuration. Deactivate invalid roles.

  def self.run(roles)
    roles.each do |role|
      if role.invalid?
        # TODO: add log entry and notification here
        role.update_columns(is_active: false)
      else
        # add additional check here in case of manual deactiovation is implemented
        role.update_columns(is_active: true)
      end
    end
  end

end