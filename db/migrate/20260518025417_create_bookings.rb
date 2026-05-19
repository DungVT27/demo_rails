class CreateBookings < ActiveRecord::Migration[8.1]
  def change
    create_table :bookings do |t|
      t.references :user, null: false, foreign_key: true
      t.references :store, null: false, foreign_key: true
      t.date :booking_date, null: false
      t.time :booking_time, null: false
      t.integer :status, default: 0, null: false

      t.timestamps
    end
  end
end
