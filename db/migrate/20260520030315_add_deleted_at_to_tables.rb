class AddDeletedAtToTables < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :deleted_at, :datetime
    add_index :users, :deleted_at
    add_column :stores, :deleted_at, :datetime
    add_index :stores, :deleted_at
    add_column :bookings, :deleted_at, :datetime
    add_index :bookings, :deleted_at
  end
end
