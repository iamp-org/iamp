class CreateRoles < ActiveRecord::Migration[7.0]
  def change
    create_table :roles, id: :uuid do |t|
      t.string      :name, null: false
      t.uuid        :system_id, null: false
      t.integer     :term
      t.string      :approval_workflow, null: false
      t.string      :provision_workflow, null: false
      t.jsonb       :approval_workflow_properties, default: {}
      t.jsonb       :provision_workflow_properties, default: {}

      t.timestamps
    end
  end
end
