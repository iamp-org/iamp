class CreateTokens < ActiveRecord::Migration[7.1]
  def change
    create_table :tokens, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.string :token
      t.datetime :expires_at

      t.timestamps
    end
  end
end
