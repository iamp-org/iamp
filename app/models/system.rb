class System < ApplicationRecord
  has_many :roles, dependent: :restrict_with_error
  has_many :permissions
  has_many :users, through: :permissions
  has_many :audit_logs, dependent: :destroy

  def self.ransackable_attributes(auth_object = nil)
    ["name"]
  end
end
