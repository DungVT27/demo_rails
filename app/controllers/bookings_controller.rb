class BookingsController < ApplicationController
  before_action :authenticate_user!
  before_action :redirect_admin_to_dashboard
  load_and_authorize_resource

  def index
    # List current user's bookings with eager loading and pagination
    @bookings = current_user.bookings.includes(:store)
                                     .order(booking_date: :desc, booking_time: :desc)
                                     .page(params[:page])
                                     .per(::AppConstants::BOOKINGS_PER_PAGE)
  end

  def create
    # Use Bookings::CreateService to encapsulate business logic
    service = Bookings::CreateService.new(current_user, booking_params)
    result = service.call

    if result.success?
      redirect_to bookings_path, success: I18n.t("app_messages.public.bookings.create_success", id: result.record.id)
    else
      # If create fails, reload the store show view with errors
      @store = Store.find(booking_params[:store_id])
      @booking = result.record
      flash.now[:alert] = I18n.t("app_messages.public.bookings.create_error", errors: result.errors.join(', '))
      render "stores/show", status: :unprocessable_entity
    end
  end

  def cancel
    # Ensure authorization (managed by load_and_authorize_resource)
    service = Bookings::CancelService.new(@booking, cancelled_by_admin: false)
    result = service.call

    if result.success?
      redirect_to bookings_path, success: I18n.t("app_messages.public.bookings.cancel_success")
    else
      redirect_to bookings_path, alert: I18n.t("app_messages.public.bookings.cancel_error", errors: result.errors.join(', '))
    end
  end

  private

  def redirect_admin_to_dashboard
    redirect_to admin_dashboard_path if current_user&.admin?
  end

  def booking_params
    params.require(:booking).permit(:store_id, :booking_date, :booking_time)
  end
end
