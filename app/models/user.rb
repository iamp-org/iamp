class User < ApplicationRecord
  has_many    :subordinates, class_name: 'User', foreign_key: 'manager_id'
  belongs_to  :manager, class_name: 'User', optional: true
  has_many    :accesses
  has_many    :audit_logs
  has_many    :permissions
  has_many    :systems, through: :permissions
  has_many    :tokens, dependent: :destroy

  def self.ransackable_attributes(auth_object = nil)
    ["displayname"]
  end

  def self.ransackable_associations(auth_object = nil)
    []
  end

end
