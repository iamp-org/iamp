class AddAutoapprovalsToRoles < ActiveRecord::Migration[7.0]
  def change
    add_column :roles, :autoapproval_workflow, :string
    add_column :roles, :autoapproval_workflow_properties, :jsonb, default: {}
  end
end
