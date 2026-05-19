# Clear existing data in correct dependency order
puts "Clearing existing data..."
Booking.destroy_all
Store.destroy_all
User.destroy_all

puts "Creating Admin Account..."
admin = User.create!(
  name: "Admin User",
  email: "admin@booking.com",
  password: "Password123!",
  password_confirmation: "Password123!",
  role: :admin
)
puts "Admin created: #{admin.email}"

puts "Creating 10 User Accounts..."
users_data = [
  { name: "Alice Smith", email: "user1@booking.com" },
  { name: "Bob Jones", email: "user2@booking.com" },
  { name: "Charlie Brown", email: "user3@booking.com" },
  { name: "Diana Prince", email: "user4@booking.com" },
  { name: "Ethan Hunt", email: "user5@booking.com" },
  { name: "Fiona Gallagher", email: "user6@booking.com" },
  { name: "George Clark", email: "user7@booking.com" },
  { name: "Hannah Abbott", email: "user8@booking.com" },
  { name: "Ian Malcolm", email: "user9@booking.com" },
  { name: "Julia Roberts", email: "user10@booking.com" }
]

users = users_data.map do |data|
  user = User.create!(
    name: data[:name],
    email: data[:email],
    password: "Password123!",
    password_confirmation: "Password123!",
    role: :user
  )
  puts "Client created: #{user.name} (#{user.email})"
  user
end

puts "Creating 2 Active Stores..."
store1 = Store.create!(
  name: "Tokyo Tire Center",
  description: "Specialized premium tire center offering comprehensive tire exchanges, wheel balancing, alignment tuning, and all-season selections for family sedans and high-performance sports cars.",
  address: "1-2-3 Shibakoen, Minato City, Tokyo",
  opening_time: "09:00",
  closing_time: "17:00",
  booking_fee: 20.00,
  status: :active
)
puts "Store created: #{store1.name} (09:00 AM - 05:00 PM, Fee: $20.00)"

store2 = Store.create!(
  name: "Osaka Auto Care",
  description: "Professional mechanical maintenance center specializing in rapid tire rotations, seasonal tire swaps, oil lubrication service, and multi-point vehicle safety inspections.",
  address: "4-5-6 Umeda, Kita Ward, Osaka",
  opening_time: "08:30",
  closing_time: "16:30",
  booking_fee: 15.00,
  status: :active
)
puts "Store created: #{store2.name} (08:30 AM - 04:30 PM, Fee: $15.00)"

puts "Creating Sample Bookings..."
# 1. Approved Booking in the future
b1 = Booking.create!(
  user: users[0], # Alice
  store: store1,
  booking_date: Date.current + 2.days,
  booking_time: "10:30",
  status: :approved
)
puts "Booking created: ##{b1.id} (Client: Alice, Store: Tokyo, Status: approved)"

# 2. Approved Booking in the future
b2 = Booking.create!(
  user: users[1], # Bob
  store: store2,
  booking_date: Date.current + 3.days,
  booking_time: "14:00",
  status: :approved
)
puts "Booking created: ##{b2.id} (Client: Bob, Store: Osaka, Status: approved)"

# 3. Completed Booking in the past
# Use past dates, but wait! Booking validations prevent booking in the past.
# Let's bypass validation for seeding past completed bookings to populate dashboard history correctly!
b3 = Booking.new(
  user: users[2], # Charlie
  store: store1,
  booking_date: Date.current - 5.days,
  booking_time: "11:00",
  status: :completed
)
b3.save!(validate: false)
puts "Booking created: ##{b3.id} (Client: Charlie, Store: Tokyo, Status: completed - bypassed date validations)"

# 4. Completed Booking in the past
b4 = Booking.new(
  user: users[3], # Diana
  store: store2,
  booking_date: Date.current - 2.days,
  booking_time: "15:30",
  status: :completed
)
b4.save!(validate: false)
puts "Booking created: ##{b4.id} (Client: Diana, Store: Osaka, Status: completed - bypassed date validations)"

# 5. Cancelled Booking in the future
b5 = Booking.create!(
  user: users[4], # Ethan
  store: store1,
  booking_date: Date.current + 5.days,
  booking_time: "16:00",
  status: :cancelled
)
puts "Booking created: ##{b5.id} (Client: Ethan, Store: Tokyo, Status: cancelled)"

# 6. Approved Booking in the future
b6 = Booking.create!(
  user: users[0], # Alice again
  store: store2,
  booking_date: Date.current + 1.day,
  booking_time: "09:00",
  status: :approved
)
puts "Booking created: ##{b6.id} (Client: Alice, Store: Osaka, Status: approved)"

puts "Seeding complete successfully!"
