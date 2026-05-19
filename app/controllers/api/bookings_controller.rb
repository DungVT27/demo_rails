class Api::BookingsController < Api::BaseController
  before_action :authenticate_api_user!

  def index
    # Returns the authenticated client's bookings including store info
    bookings = current_user.bookings.includes(:store).order(booking_date: :desc, booking_time: :desc)
    render json: bookings.as_json(
      include: { store: { only: [ :id, :name, :address, :booking_fee ] } },
      only: [ :id, :booking_date, :booking_time, :status, :created_at ]
    ), status: :ok
  end

  def create
    service = Bookings::CreateService.new(current_user, booking_params)
    result = service.call

    if result.success?
      render json: result.record.as_json(
        include: { store: { only: [ :id, :name, :address, :booking_fee ] } },
        only: [ :id, :booking_date, :booking_time, :status, :created_at ]
      ), status: :created
    else
      render json: { errors: result.errors }, status: :unprocessable_entity
    end
  end

  def update
    # If admin, search all bookings. Otherwise, search only the current user's bookings.
    booking = current_user.admin? ? Booking.find(params[:id]) : current_user.bookings.find(params[:id])
    status = params[:status]

    if status == "cancelled"
      service = Bookings::CancelService.new(booking, cancelled_by_admin: current_user.admin?)
      result = service.call
    elsif status == "completed"
      unless current_user.admin?
        render json: { error: "Only administrators can transition a booking status to completed." }, status: :forbidden
        return
      end
      service = Bookings::CompleteService.new(booking)
      result = service.call
    else
      render json: { error: "Invalid status value. Permissible updates are 'cancelled' or 'completed'." }, status: :bad_request
      return
    end

    if result.success?
      render json: result.record.as_json(
        include: { store: { only: [ :id, :name, :address, :booking_fee ] } },
        only: [ :id, :booking_date, :booking_time, :status, :updated_at ]
      ), status: :ok
    else
      render json: { errors: result.errors }, status: :unprocessable_entity
    end
  end

  private

  def booking_params
    params.require(:booking).permit(:store_id, :booking_date, :booking_time)
  end
end
