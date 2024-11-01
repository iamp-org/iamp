class AddWorkflowFieldsToRoles < ActiveRecord::Migration[7.0]
  def change
    remove_column :roles, :approval_workflow,         :string
    remove_column :roles, :provision_workflow,        :string
    add_column    :roles, :approval_workflow_id,      :uuid
    add_column    :roles, :autoapproval_workflow_id,  :uuid
    add_column    :roles, :provision_workflow_id,     :uuid
  end
end
