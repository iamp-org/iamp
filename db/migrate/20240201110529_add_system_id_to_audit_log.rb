class AddSystemIdToAuditLog < ActiveRecord::Migration[7.0]
  def change
    add_reference :audit_logs, :system, foreign_key: true, type: :uuid
  end
end
