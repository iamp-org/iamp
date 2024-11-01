class AuditLog < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :system, optional: true

  enum event_type: {
    access_approved: 'access_approved',
    access_declined: 'access_declined',
    access_revoked:  'access_revoked',
    role_created:    'role_created',
    role_updated:    'role_updated',
    role_removed:    'role_removed'
  }

  def self.ransackable_attributes(auth_object = nil)
    ["event_description"]
  end

  def self.ransackable_associations(auth_object = nil)
    []
  end

end