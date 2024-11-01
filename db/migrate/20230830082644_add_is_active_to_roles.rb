class AddIsActiveToRoles < ActiveRecord::Migration[7.0]
  def change
    add_column :roles, :is_active, :boolean, default: true
  end
end
