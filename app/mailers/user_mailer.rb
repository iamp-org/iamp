class UserMailer < ApplicationMailer
  default from: "IAMP <#{ENV.fetch("SMTP_USERNAME")}>"

  def access_requested(access)
    @access       = access
    @title        = "Access request has been submitted"
    @button       = "See status"

    # collect current approvers
    lists = (1..3).flat_map { |i| access.role.approval_workflow_properties["list#{i}"] }.compact
    @approvers = User.where(id: lists).pluck(:displayname).compact

    recipient = access.requestor&.email
    
    if Rails.env.development?
      mail(to: [ENV.fetch("DEVELOPER_EMAIL")], subject: 'IAMP notification (dev)')
    else
      if recipient.present?
        mail(to: recipient, subject: 'IAMP notification')
      end
    end
  end

  def access_pending_approval(access)
    @access       = access
    @title        = "Access request is pending your approval"
    @button       = "Make decision"

    # collect current approvers
    lists = (1..3).flat_map { |i| access.role.approval_workflow_properties["list#{i}"] }.compact
    approvers = User.where(id: lists).pluck(:email).compact
    recipients = approvers
    
    if Rails.env.development?
      mail(to: [ENV.fetch("DEVELOPER_EMAIL")], subject: 'IAMP notification (dev)')
    else
      if recipients.present?
        mail(to: recipients, subject: 'IAMP notification')
      end
    end
  end

  def access_approved(access)
    @access   = access
    @title    = "Your access request has been approved"
    @button   = "IAMP"
    if Rails.env.development?
      mail(to: [ENV.fetch("DEVELOPER_EMAIL")], subject: 'IAMP notification (dev)')
    else 
      recipient = access.requestor&.email
      if recipient.present?
        mail(to: recipient, subject: 'IAMP notification')
      end
    end
  end

  def access_declined(access, comment)
    @access   = access
    @comment  = comment
    @title    = "Your access request has been declined"
    @button   = "IAMP"
    if Rails.env.development?
      mail(to: [ENV.fetch("DEVELOPER_EMAIL")], subject: 'IAMP notification (dev)')
    else
      recipient = access.requestor&.email
      if recipient.present?
        mail(to: recipient, subject: 'IAMP notification')
      end
    end
  end

  def access_revoked(access, comment)
    @access   = access
    @comment  = comment
    @title    = "Your access has been revoked"
    @button   = "IAMP"
    if Rails.env.development?
      mail(to: [ENV.fetch("DEVELOPER_EMAIL")], subject: 'IAMP notification (dev)')
    else 
      recipient = access.requestor&.email
      if recipient.present?
        mail(to: recipient, subject: 'IAMP notification')
      end
    end
  end

  def role_inactive(role, owner)
    @role   = role
    @title    = "Access role is inactive"
    @button   = "IAMP"
    if Rails.env.development?
      mail(to: [ENV.fetch("DEVELOPER_EMAIL")], subject: 'IAMP notification (dev)')
    else 
      recipient = owner&.email
      if recipient.present?
        mail(to: recipient, subject: 'IAMP notification')
      end
    end
  end

end