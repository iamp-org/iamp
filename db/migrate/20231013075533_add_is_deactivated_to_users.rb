class AddIsDeactivatedToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :is_deactivated, :boolean, default: false
  end
end
