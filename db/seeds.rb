# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)


## Admin assigments. Define ADMINS env variable with comma separated usernames
## TODO: mode this to UI?
# admin_usernames = ENV.fetch("ADMINS", "").split(",").map(&:strip)
# admin_usernames.each do |username|
#   user = User.find_by(username: username)
#   if user
#     user.update(is_admin: true)
#     Rails.logger.info("Admin privileges assigned to #{user.username}")
#   end
# end


# Create workflows.
# ApprovalWorkflow.new(name: "SimpleList", description: "1 approval from the list makes access request approved").save
# ApprovalWorkflow.new(name: "SimpleList & PrioritizedList", description: "1 approval from the first list makes access request partially approved. 1 approval from the prioritized list makes access request finally approved").save
# AutoapprovalWorkflow.new(name: "LDAPDirectManager", description: "Having direct manager from the list makes access request approved automatically").save
# AutoapprovalWorkflow.new(name: "LDAPGroupMembership", description: "Memberships in any group from the list makes access request approved automatically").save
# AutoapprovalWorkflow.new(name: "NoCondition", description: "Access request is approved automatically just when requested").save
# AutoapprovalWorkflow.new(name: "LDAPManagerInChain", description: "Having manager in chain from the list makes access request approved automatically").save
# AutoapprovalWorkflow.new(name: "LDAPStringInDN", description:  "Access request approved automatically if user's DistinguishedName contains a string from the list").save
# ProvisionWorkflow.new(name: "LDAPGroupMembership", description: "Memberships in all LDAP groups in the list").save
AutodenialWorkflow.new(name: "LDAPGroupMembershipLimit", description: "Reaching the specified limit of accesses makes access request declined automatically").save