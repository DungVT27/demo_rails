class Api::StoresController < Api::BaseController
  def index
    # Returns only active stores in alphabetical order
    stores = Store.active.order(name: :desc)
    render json: stores.as_json(only: [ :id, :name, :description, :address, :opening_time, :closing_time, :booking_fee, :status ]), status: :ok
  end

  def show
    store = Store.active.find(params[:id])
    render json: store.as_json(only: [ :id, :name, :description, :address, :opening_time, :closing_time, :booking_fee, :status ]), status: :ok
  end
end
