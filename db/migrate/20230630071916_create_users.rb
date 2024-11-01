class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users, id: :uuid do |t|
      t.string    :displayname, null: false
      t.string    :username, null: false
      t.string    :dn
      t.string    :email
      t.string    :position
      t.string    :team
      t.string    :company
      t.uuid      :manager_id
      t.boolean   :is_admin, default: false
      t.boolean   :is_service, default: false

      t.timestamps
    end
  end
end
