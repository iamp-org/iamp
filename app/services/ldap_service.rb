class LdapService
  def initialize(ldap_host, ldap_port, ldap_base)
    @ldap = Net::LDAP.new(
      host: ldap_host,
      port: ldap_port,
      base: ldap_base,
      connect_timeout: 30,
      encryption: {
        method: :simple_tls,
        tls_options: {
          ssl_version: 'TLSv1_2',
          verify_mode: OpenSSL::SSL::VERIFY_PEER
        }
      }
    )
  end

  def authenticate(username, password)
    @ldap.auth username, password
    return @ldap if @ldap.bind
  end

  def sync_users(searchbase, filter, attrs_mapping, is_service=false)
    attributes = attrs_mapping.values
    active_users = []
    searchbase.each do |base|
      @ldap.search(base: base, filter: filter, attributes: attributes) do |entry|
        id              = GuidSplitterService.unpack_guid(entry[attrs_mapping[:id]].first)
        username        = entry[attrs_mapping[:username]].first&.downcase
        displayname     = entry[attrs_mapping[:displayname]].first
        next if username.nil? || displayname.nil?
        dn              = entry[attrs_mapping[:dn]].first
        email           = entry[attrs_mapping[:email]]&.first
        company         = entry[attrs_mapping[:company]]&.first
        position        = entry[attrs_mapping[:position]]&.first
        team            = entry[attrs_mapping[:team]]&.first

        manager_id  = User.find_by_dn(entry[attrs_mapping[:manager_id]].first)&.id
        active_users << id
        active_user = User.find_or_initialize_by(id: id)
        active_user.assign_attributes(
          username:     username,
          displayname:  displayname,
          dn:           dn,
          email:        email,
          company:      company,
          position:     position,
          team:         team,
          manager_id:   manager_id,
          is_service:   is_service,
          is_active:    true
        )

        # assign posix attrs only if not assigned
        active_user.uid_number      = PosixService.generate_unique_uid_number if active_user.uid_number.blank?
        active_user.home_directory  = "/home/#{username}" if active_user.home_directory.blank?
        active_user.login_shell     = "/bin/bash" if active_user.login_shell.blank?

        active_user.save
      end
    end

    all_users = User.where(is_service: is_service)
    all_users.each do |user|
      user.update(
        is_active:    false,
        email:        nil,
        company:      nil,
        position:     nil,
        team:         nil,
        manager_id:   nil,
        dn:           nil,
        displayname:  "#{user.username} (inactive)"
      ) unless active_users.include?(user.id)
    end
    
  end

  def get_objects(searchbase, filter, attributes)
    result = []
    searchbase.each do |base|
      @ldap.search(base: base, filter: filter, attributes: attributes) do |entry|
        result << entry
      end
    end
    return result
  end

  def search(searchbase, filter, attributes)
    @ldap.search(base: searchbase, filter: filter, attributes: attributes)
  end

  def modify(dn, operations)
    @ldap.modify dn: dn, operations: operations
  end

  def add(dn, attributes)
    @ldap.add dn: dn, attributes: attributes
  end

end