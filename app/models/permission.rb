class Permission < ApplicationRecord
  belongs_to :user
  belongs_to :system

  validates :user_id, uniqueness: { scope: :system_id, message: "already has permission for this system" }

  ransack_alias :user_or_system, :user_displayname_or_system_name

  def self.ransackable_attributes(auth_object = nil)
    ["user_or_system"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["system", "user"]
  end

end
