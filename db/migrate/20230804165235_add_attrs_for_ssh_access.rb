class AddAttrsForSshAccess < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :sshkey, :text
    add_column :users, :uid_number, :string
    add_column :users, :home_directory, :string
    add_column :users, :login_shell, :string
  end
end
