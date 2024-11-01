class CreatePermissions < ActiveRecord::Migration[7.0]
  def change
    create_table :permissions, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.references :system, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
