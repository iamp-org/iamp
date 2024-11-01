class Access < ApplicationRecord
  belongs_to :role
  belongs_to :user
  belongs_to :requestor, class_name: 'User', foreign_key: :requestor_id, optional: true

  validates :role_id, uniqueness: { scope: :user_id }

  def self.ransackable_attributes(auth_object = nil)
    ["user"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["user"]
  end

end
