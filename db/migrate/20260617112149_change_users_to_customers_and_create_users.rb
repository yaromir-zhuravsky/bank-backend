class ChangeUsersToCustomersAndCreateUsers < ActiveRecord::Migration[8.1]
  def change
      rename_table :users, :customers
      rename_column :accounts, :user_id, :customer_id

      create_table :users do |t|
        t.timestamps
      end

      add_column :customers, :user_id, :bigint, null: false
      add_foreign_key :customers, :users
      add_index :customers, :user_id, unique: true
  end
end
