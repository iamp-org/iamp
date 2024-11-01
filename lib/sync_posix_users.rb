puts "Users POSIX sync"

begin
  ldap = LdapService.new(
    ENV.fetch("OL_HOSTNAME"), 
    Rails.application.config.ldap_port,
    ENV.fetch("OL_BASE")
    )
  if ldap.authenticate(
    ENV.fetch("OL_USERNAME"),
    ENV.fetch("OL_PASSWORD")
    )

    # Synchronize posix accounts
    iamp_users = User.where(is_service: false, is_active: true)

    searchbase     = "OU=users,#{ENV.fetch("OL_BASE")}"
    filter         = '(objectClass=posixAccount)'
    attrs          = %w[dn uid uidNumber sshPublicKey home_directory]

    search_result = ldap.search(searchbase, filter, attrs)
    ol_users = []
    search_result.each do |entry|
      ol_user = {
        uidNumber: entry[:uidNumber].first,
        dn: entry[:dn].first&.downcase,
        uid: entry[:uid].first&.downcase,
        sshPublicKey: entry[:sshPublicKey]&.first
      }
      ol_users << ol_user
    end

    iamp_users.each do |user|
      matched_posix_account = ol_users.find { |account| account[:uidNumber] == user.uid_number }
      # puts matched_posix_account
      if matched_posix_account
        ldap.modify(matched_posix_account[:dn], [[:replace, :sshPublicKey, user.sshkey]]) if matched_posix_account[:sshPublicKey] != user.sshkey
        ldap.modify(matched_posix_account[:dn], [[:replace, :homedirectory, user.home_directory]]) if matched_posix_account[:homedirectory] != user.home_directory
      else
        user_attrs = {
          objectclass: %w[top inetorgperson posixaccount ldappublickey],
          cn: user.displayname,
          sn: user.username,
          mail: user.email,
          uid: user.username,
          uidNumber: user.uid_number,
          gidNumber: user.uid_number,
          homedirectory: user.home_directory,
          loginshell: user.login_shell,
          sshPublicKey: user.sshkey
        }.compact
        dn = "uid=" + user.username + ",ou=users," + ENV.fetch("OL_BASE")
        ldap.add(dn, user_attrs)
      end
    end

  end
rescue StandardError => e
  Rails.logger.error "Error on POSIX users sync: #{e.message}"
  Rails.logger.error e.backtrace.join("\n")
end
