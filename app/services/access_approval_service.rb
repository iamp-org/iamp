class AccessApprovalService

  def self.get_approvers(role)
    # Obtain current approvers based on workflow
    case role.approval_workflow&.name
    when "SimpleList", "SimpleList & PrioritizedList"
      lists = (1..3).map { |i| role.approval_workflow_properties["list#{i}"] }
      approvers = lists.flatten.compact.map { |approver| User.select(:id, :displayname).find(approver) }
    else
      []
    end
  end

  def self.handle_approval(access, current_user)
    # Verify approvals against assigned workflow to make access approved and notify requestor.
    # Set expiration if nedeed.
    case access.role.approval_workflow&.name
    when "SimpleList"
      if access.approvals.any? { |approver_id| access.role.approval_workflow_properties["list1"].include?(approver_id) }
        access.update(approved: true, expires_at: access.role.term.present? ? DateTime.now + access.role.term : nil)
        TriggerIamJob.perform_later(access.role)
        AuditLog.create(
          user_id:            current_user.id,
          system_id:          access.role.system.id,
          event_type:         :access_approved,
          event_description:  "Access request approved by #{current_user.displayname}. User: #{access.user.displayname}. System: #{access.role.system.name}. Role: #{access.role.name}"
        )
        UserMailer.access_approved(access).deliver_later
      end
    when "SimpleList & PrioritizedList"
      if access.approvals.any? { |approver_id| access.role.approval_workflow_properties["list2"].include?(approver_id) }
          access.update(approved: true, expires_at: access.role.term.present? ? DateTime.now + access.role.term : nil)
          TriggerIamJob.perform_later(access.role)
          AuditLog.create(
            user_id:            current_user.id,
            system_id:          access.role.system.id,
            event_type:         :access_approved,
            event_description:  "Access request approved by #{current_user.displayname}. User: #{access.user.displayname}. System: #{access.role.system.name}. Role: #{access.role.name}"
          )
          UserMailer.access_approved(access).deliver_later
      end
    end
  end

end