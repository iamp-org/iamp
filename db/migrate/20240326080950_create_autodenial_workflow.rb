class CreateAutodenialWorkflow < ActiveRecord::Migration[7.0]
  def change
    create_table :autodenial_workflows, id: :uuid do |t|
      t.string      :name, null: false
      t.text        :description

      t.timestamps
    end
    add_column    :roles, :autodenial_workflow_id,  :uuid
    add_column    :roles, :autodenial_workflow_properties, :jsonb, default: {}
  end
end