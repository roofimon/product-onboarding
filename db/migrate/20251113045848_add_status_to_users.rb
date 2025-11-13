class AddStatusToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :status, :integer, default: 0, null: false
    add_index :users, :status
  end
end
