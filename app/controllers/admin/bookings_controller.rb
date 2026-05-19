class Admin::BookingsController < Admin::BaseController
  before_action :set_booking, only: [:show, :cancel, :complete]

  def index
    # Search and filter bookings using Ransack (by date, store, user, status)
    @q = Booking.ransack(params[:q])
    @bookings = @q.result(distinct: true)
                  .includes(:user, :store)
                  .order(booking_date: :desc, booking_time: :desc)

    respond_to do |format|
      format.html { @bookings = @bookings.page(params[:page]).per(::Constants::BOOKINGS_PER_PAGE) }
      format.csv { send_data generate_csv(@bookings), filename: "bookings-#{Date.today}.csv" }
    end
  end

  def show
  end

  def cancel
    # Delegate cancellation logic to service which triggers email sending
    service = Bookings::CancelService.new(@booking, cancelled_by_admin: true)
    result = service.call

    if result.success?
      redirect_to admin_bookings_path, success: I18n.t("messages.admin.bookings.cancel_success", id: @booking.id, user_name: @booking.user.name)
    else
      redirect_to admin_booking_path(@booking), alert: I18n.t("messages.admin.bookings.cancel_error", errors: result.errors.join(', '))
    end
  end

  def complete
    # Delegate completion logic to service
    service = Bookings::CompleteService.new(@booking)
    result = service.call

    if result.success?
      redirect_to admin_bookings_path, success: I18n.t("messages.admin.bookings.complete_success", id: @booking.id)
    else
      redirect_to admin_booking_path(@booking), alert: I18n.t("messages.admin.bookings.complete_error", errors: result.errors.join(', '))
    end
  end

  private

  def set_booking
    @booking = Booking.find(params[:id])
  end

  def generate_csv(bookings)
    require "csv"
    CSV.generate(headers: true) do |csv|
      csv << ["Booking ID", "User Name", "User Email", "Store Name", "Date", "Time", "Booking Fee", "Status", "Created At"]
      bookings.each do |booking|
        csv << [
          booking.id,
          booking.user.name,
          booking.user.email,
          booking.store.name,
          booking.booking_date,
          booking.booking_time.strftime("%I:%M %p"),
          "$#{'%.2f' % booking.store.booking_fee}",
          booking.status,
          booking.created_at.strftime("%Y-%m-%d %H:%M:%S")
        ]
      end
    end
  end
end
