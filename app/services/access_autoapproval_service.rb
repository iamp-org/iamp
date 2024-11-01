class AccessAutoapprovalService

  def self.handle_autoapproval(access)
    # Verify against assigned autoapproval workflow.
    # Set expiration if nedeed.
    case access.role.autoapproval_workflow&.name

    when "NoCondition"
      access.update(approved: true, expires_at: access.role.term.present? ? DateTime.now + access.role.term : nil)
      TriggerIamJob.perform_later(access.role)
      AuditLog.create(
        system_id:          access.role.system.id,
        event_type:         :access_approved,
        event_description:  "Access request approved by automation. User: #{access.user.displayname}. System: #{access.role.system.name}. Role: #{access.role.name}"
      )
      UserMailer.access_approved(access).deliver_later

    when "LDAPStringInDN"
      strings = access.role.autoapproval_workflow_properties["list1"]
      matching_string = strings.find { |string| access.user.dn.downcase.include?(string.downcase) }
      if matching_string
        access.update(approved: true, expires_at: access.role.term.present? ? DateTime.now + access.role.term : nil)
        TriggerIamJob.perform_later(access.role)
        AuditLog.create(
          system_id:          access.role.system.id,
          event_type:         :access_approved,
          event_description:  "Access request approved by automation. User: #{access.user.displayname}. System: #{access.role.system.name}. Role: #{access.role.name}"
        )
        UserMailer.access_approved(access).deliver_later
      end

    when "LDAPManagerInChain"
      ldap = LdapService.new(
        Rails.application.config.ldap_host, 
        Rails.application.config.ldap_port,
        Rails.application.config.ldap_base
        )
      if ldap.authenticate(
        Rails.application.config.ldap_username,
        Rails.application.config.ldap_password
        )
        managers = User.find(access.role.autoapproval_workflow_properties["list1"]).map { |item| "(manager=#{item.dn})" }.join

        def self.lookup_manager(dn, ldap, managers)
          entry = ldap.search(
            dn,
            "(&(objectCategory=Person)(!(UserAccountControl:1.2.840.113556.1.4.803:=2)))",
            %w[manager]).first
          manager = entry[:manager]&.first
      
          if manager.present? && manager != dn
            if managers.include? manager
              return true
            else
              return true if self.lookup_manager(manager, ldap, managers)
            end
          end
        end

        if self.lookup_manager(access.user.dn, ldap, managers)
          access.update(approved: true, expires_at: access.role.term.present? ? DateTime.now + access.role.term : nil)
          TriggerIamJob.perform_later(access.role)
          AuditLog.create(
            system_id:          access.role.system.id,
            event_type:         :access_approved,
            event_description:  "Access request approved by automation. User: #{access.user.displayname}. System: #{access.role.system.name}. Role: #{access.role.name}"
          )
          UserMailer.access_approved(access).deliver_later
        else
          UserMailer.access_pending_approval(access).deliver_later
        end
      end

    when "LDAPDirectManager"
      ldap = LdapService.new(
        Rails.application.config.ldap_host, 
        Rails.application.config.ldap_port,
        Rails.application.config.ldap_base
        )
      if ldap.authenticate(
        Rails.application.config.ldap_username,
        Rails.application.config.ldap_password
        )
        managers = User.find(access.role.autoapproval_workflow_properties["list1"]).map { |item| "(manager=#{item.dn})" }.join
        objects = ldap.get_objects(
          Rails.application.config.ldap_user_accounts_searchbase,
          "(&(distinguishedName=#{access.user.dn})(|#{managers}))",
          "dn"
        )
        if objects.any?
          access.update(approved: true, expires_at: access.role.term.present? ? DateTime.now + access.role.term : nil)
          TriggerIamJob.perform_later(access.role)
          AuditLog.create(
            system_id:          access.role.system.id,
            event_type:         :access_approved,
            event_description:  "Access request approved by automation. User: #{access.user.displayname}. System: #{access.role.system.name}. Role: #{access.role.name}"
          )
          UserMailer.access_approved(access).deliver_later
        else
          UserMailer.access_pending_approval(access).deliver_later
        end
      end
    when "LDAPGroupMembership"
      ldap = LdapService.new(
        Rails.application.config.ldap_host, 
        Rails.application.config.ldap_port,
        Rails.application.config.ldap_base
        )
      if ldap.authenticate(
        Rails.application.config.ldap_username,
        Rails.application.config.ldap_password
        )
        groups = access.role.autoapproval_workflow_properties["list1"].map { |dn| "(memberOf=#{dn})" }.join
        objects = ldap.get_objects(
          Rails.application.config.ldap_user_accounts_searchbase,
          "(&(distinguishedName=#{access.user.dn})(|#{groups}))",
          "dn"
        )
        if objects.any?
          access.update(approved: true, expires_at: access.role.term.present? ? DateTime.now + access.role.term : nil)
          TriggerIamJob.perform_later(access.role)
          UserMailer.access_approved(access).deliver_later
          AuditLog.create(
            system_id:          access.role.system.id,
            event_type:         :access_approved,
            event_description:  "Access request approved by automation. User: #{access.user.displayname}. System: #{access.role.system.name}. Role: #{access.role.name}"
          )
        else
          UserMailer.access_pending_approval(access).deliver_later
        end
      end
    end
  end

end