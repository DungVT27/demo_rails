namespace :bookings do
  desc "Auto-complete approved bookings whose date and time slot have passed"
  task auto_complete: :environment do
    puts "[#{Time.current}] Starting auto-complete bookings task..."

    completed_count = Booking.auto_complete_passed!

    puts "[#{Time.current}] Completed task. Successfully marked #{completed_count} booking(s) as COMPLETED."
  end
end
