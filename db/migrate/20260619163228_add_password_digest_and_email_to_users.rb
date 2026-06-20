class AddPasswordDigestAndEmailToUsers < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!
  def change
    add_column :users, :password_digest, :string, null: false
    add_column :users, :email, :string, null: false

    add_index :users, :email, unique: true, algorithm: :concurrently
  end
end
