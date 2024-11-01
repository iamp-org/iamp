class CreateWorkflows < ActiveRecord::Migration[7.0]
  def change
    create_table :approval_workflows, id: :uuid do |t|
      t.string      :name, null: false
      t.text        :description

      t.timestamps
    end

    create_table :autoapproval_workflows, id: :uuid do |t|
      t.string      :name, null: false
      t.text        :description
      
      t.timestamps
    end

    create_table :provision_workflows, id: :uuid do |t|
      t.string      :name, null: false
      t.text        :description

      t.timestamps
    end
  end
end
