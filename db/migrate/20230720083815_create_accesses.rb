class CreateAccesses < ActiveRecord::Migration[7.0]
  def change
    create_table :accesses, id: :uuid do |t|
      t.uuid        :role_id, null: false
      t.uuid        :user_id, null: false
      t.text        :justification
      t.datetime    :expiration
      t.string      :approvals, array: true, default: []
      t.boolean     :approved, default: false, null: false

      t.timestamps
    end
  end
end

