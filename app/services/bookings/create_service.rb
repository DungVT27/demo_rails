module Bookings
  class CreateService
    def initialize(user, params)
      @user = user
      @params = params
    end

    def call
      booking = @user.bookings.build(@params)
      booking.status = :approved # Default status on creation

      if booking.save
        BookingMailer.booking_created_email(booking).deliver_later
        ServiceResult.new(true, booking)
      else
        ServiceResult.new(false, booking, booking.errors.full_messages)
      end
    end
  end
end
