module Bookings
  class CancelService
    def initialize(booking, cancelled_by_admin: false)
      @booking = booking
      @cancelled_by_admin = cancelled_by_admin
    end

    def call
      unless @cancelled_by_admin
        # Combine booking_date and booking_time to verify 1-day advance limit
        booking_datetime = Time.zone.local(
          @booking.booking_date.year,
          @booking.booking_date.month,
          @booking.booking_date.day,
          @booking.booking_time.hour,
          @booking.booking_time.min
        )

        if Time.current > (booking_datetime - 1.day)
          return ServiceResult.new(false, @booking, [ "You can only cancel your booking at least 1 day before the scheduled booking time." ])
        end
      end

      if @booking.update(status: :cancelled)
        # Send email notification to user for all cancellations, passing who cancelled it
        BookingMailer.booking_cancelled_email(@booking, cancelled_by_admin: @cancelled_by_admin).deliver_later
        ServiceResult.new(true, @booking)
      else
        ServiceResult.new(false, @booking, @booking.errors.full_messages)
      end
    end
  end
end
