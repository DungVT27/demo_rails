class BookingMailer < ApplicationMailer
  # Dynamically pull sender name and address from env variables with sensible fallbacks
  default from: -> { ActionMailer::Base.email_address_with_name(ENV.fetch("MAIL_FROM_ADDRESS", "noreply@booking.com"), ENV.fetch("MAIL_FROM_NAME", "Booking System")) }

  def booking_cancelled_email(booking, cancelled_by_admin: true)
    @booking = booking
    @user = booking.user
    @store = booking.store
    @cancelled_by_admin = cancelled_by_admin

    mail(
      to: @user.email,
      subject: "Booking Cancellation: #{@store.name}"
    )
  end

  def booking_created_email(booking)
    @booking = booking
    @user = booking.user
    @store = booking.store

    mail(
      to: @user.email,
      subject: "Booking Confirmed: #{@store.name}"
    )
  end
end
