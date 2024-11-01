class AccessAutodenialService

  def self.handle_autodenial(access)
    case access.role.autodenial_workflow&.name
    when "LDAPGroupMembershipLimit"
      if access.role.provision_workflow&.name == "LDAPGroupMembership"
        accesses = Access.where(role: access.role)
        if accesses.count >= access.role.autodenial_workflow_properties["limit"].to_i
          access.destroy
          AuditLog.create(
            system_id:          access.role.system.id,
            event_type:         :access_declined,
            event_description:  "Access request declined by automation. User: #{access.user.displayname}. System: #{access.role.system.name}. Role: #{access.role.name}"
          )
        end
      end
    end
  end

end