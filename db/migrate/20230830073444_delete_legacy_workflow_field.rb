class DeleteLegacyWorkflowField < ActiveRecord::Migration[7.0]
  def change
    remove_column :roles, :autoapproval_workflow, :string
  end
end
