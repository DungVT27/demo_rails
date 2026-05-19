class CreateStores < ActiveRecord::Migration[8.1]
  def change
    create_table :stores do |t|
      t.string :name, null: false
      t.text :description
      t.string :address, null: false
      t.time :opening_time, null: false
      t.time :closing_time, null: false
      t.decimal :booking_fee, precision: 8, scale: 2, default: 0.0, null: false
      t.integer :status, default: 0, null: false

      t.timestamps
    end
  end
end
