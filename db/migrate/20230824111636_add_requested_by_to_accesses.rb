class AddRequestedByToAccesses < ActiveRecord::Migration[7.0]
  def change
    add_column :accesses, :requestor_id, :uuid
  end
end
