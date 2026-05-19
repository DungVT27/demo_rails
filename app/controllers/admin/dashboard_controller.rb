class Admin::DashboardController < Admin::BaseController
  def index
    @total_stores = Store.count
    @total_users = User.user.count
    @total_bookings = Booking.count
    
    # Calculate estimated revenue based on approved or completed bookings
    @total_revenue = Booking.where(status: [:approved, :completed]).joins(:store).sum("stores.booking_fee")

    # Booking status breakdown
    @approved_bookings = Booking.approved.count
    @cancelled_bookings = Booking.cancelled.count
    @completed_bookings = Booking.completed.count

    # Recent bookings
    @recent_bookings = Booking.includes(:user, :store).order(created_at: :desc).limit(::Constants::RECENT_BOOKINGS_LIMIT)

    # Popular stores (top 5 by booking count)
    @popular_stores = Store.select("stores.*, COUNT(bookings.id) as bookings_count")
                          .joins(:bookings)
                          .group("stores.id")
                          .order("bookings_count DESC")
                          .limit(::Constants::TOP_STORES_LIMIT)
  end
end
