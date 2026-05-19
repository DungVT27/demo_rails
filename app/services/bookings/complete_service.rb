module Bookings
  class CompleteService
    def initialize(booking)
      @booking = booking
    end

    def call
      if @booking.update(status: :completed)
        ServiceResult.new(true, @booking)
      else
        ServiceResult.new(false, @booking, @booking.errors.full_messages)
      end
    end
  end
end
