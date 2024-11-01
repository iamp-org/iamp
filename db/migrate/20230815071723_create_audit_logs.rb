class CreateAuditLogs < ActiveRecord::Migration[7.0]
  def change
    create_table :audit_logs, id: :uuid do |t|
      t.uuid   :user_id
      t.string :event_type, null: false
      t.text   :event_description

      t.timestamps
    end
  end
end
