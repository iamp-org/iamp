class RenameExpirationColumn < ActiveRecord::Migration[7.0]
  def change
    rename_column :accesses, :expiration, :expires_at
  end
end
