class AccessProvisionService

  def self.run(role)
    puts "Provision for system: #{role.system.name}, role: #{role.name}"

    case role.provision_workflow&.name
    when "LDAPGroupMembership"
      role.provision_workflow_properties["list1"].each do |group|
        # TODO: rework this. Implement matching in application.rb to support unlimited number of domains
        if group.downcase.include?(Rails.application.config.ldap_base&.downcase)
          username = Rails.application.config.ldap_username
          password = Rails.application.config.ldap_password
          base     = Rails.application.config.ldap_base
          filter   = "(&(objectClass=user)(memberOf:1.2.840.113556.1.4.1941:=#{group}))"
          attrs    = %w[dn]
          ldap = LdapService.new(Rails.application.config.ldap_host, Rails.application.config.ldap_port, base)
          if ldap.authenticate(username, password)
            search_result       = ldap.search(base, filter, attrs)
            memberships         = search_result.map { |entry| entry[:dn].first }

            if role.provision_workflow_properties&.fetch('preserve_members', false)
              memberships.each do |member|
                user = User.find_by(dn: member)
                Access.create(
                  role_id: role.id,
                  user_id: user.id,
                  expires_at: role.term.present? ? DateTime.now + role.term : nil,
                  approved: true
                )
              end
              role.provision_workflow_properties.delete('preserve_members')
              role.save
            end
            
            accesses = Access.where(approved: true, role_id: role.id).map { |access| access.user&.dn }.compact

            if accesses.sort != memberships.sort
              members_to_add = accesses - memberships
              members_to_remove = memberships - accesses
              members_to_add.each do |member_dn|
                ldap.modify(group, [[:add, :member, member_dn]])
              end
              members_to_remove.each do |member_dn|
                ldap.modify(group, [[:delete, :member, member_dn]])
              end
            end
          end
        elsif group.downcase.include?(ENV.fetch("OL_BASE")&.downcase)
          username = ENV.fetch("OL_USERNAME")
          password = ENV.fetch("OL_PASSWORD")
          base     = group
          filter   = '(objectClass=posixGroup)'
          attrs    = %w[memberUid]
          ldap = LdapService.new(ENV.fetch("OL_HOSTNAME"), Rails.application.config.ldap_port, base)
          if ldap.authenticate(username, password)
            search_result     = ldap.search(base, filter, attrs)
            memberships       = search_result.first[:memberUid]

            if role.provision_workflow_properties&.fetch('preserve_members', false)
              memberships.each do |member|
                user = User.find_by(username: member)
                Access.create(
                  role_id: role.id,
                  user_id: user.id,
                  expires_at: role.term.present? ? DateTime.now + role.term : nil,
                  approved: true
                )
              end
              role.provision_workflow_properties.delete('preserve_members')
              role.save
            end

            accesses = Access.where(approved: true, role_id: role.id).map { |access| access.user&.username }.compact

            if accesses.sort != memberships.sort
              members_to_add = accesses - memberships
              members_to_remove = memberships - accesses
              members_to_add.each do |member_dn|
                ldap.modify(group, [[:add, :memberUid, member_dn]])
              end
              members_to_remove.each do |member_dn|
                ldap.modify(group, [[:delete, :memberUid, member_dn]])
              end
            end
          end

        else
          next
        end
      end

    end

  end

end